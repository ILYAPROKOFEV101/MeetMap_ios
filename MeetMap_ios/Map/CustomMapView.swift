//
//  CustomMapView.swift
//  MeetMap_ios
//
//  Created by Ilya Prokofev on 28.07.2024.
//

import SwiftUI
import Foundation
import CoreLocation
import MapKit
import SwiftUI


struct CustomMapView: UIViewRepresentable {
    @Binding var coordinateRegion: MKCoordinateRegion
    @Binding var mapType: MKMapType
    @ObservedObject var markerStore: MarkerStore
    @Binding var uid: String
    @Binding var key: String
    @Binding var userLocation: CLLocationCoordinate2D
    @State private var isMapTypeChanged = false
    @State private var shouldUpdateMarkers = true
    @State private var isLoadingMarkers = false

    func makeUIView(context: Context) -> MKMapView {	
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.mapType = mapType

        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
        
        return mapView
    }
   

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Убедитесь, что обновление карты игнорируется при изменении типа карты
        if uiView.mapType != mapType {
            uiView.mapType = mapType
            isMapTypeChanged = true
            shouldUpdateMarkers = false // Не обновляем маркеры при изменении типа карты
            return // Возвращаемся, чтобы остановить дальнейшие обновления
        }

        // Убедитесь, что обновление карты игнорируется при изменении региона
        if isMapTypeChanged {
            isMapTypeChanged = false
            return // Возвращаемся, чтобы остановить дальнейшие обновления
        }

        // Обновляем регион карты только если он изменился и не было изменения типа карты
        if !isMapTypeChanged {
            if uiView.region.center.latitude != coordinateRegion.center.latitude ||
                uiView.region.center.longitude != coordinateRegion.center.longitude ||
                uiView.region.span.latitudeDelta != coordinateRegion.span.latitudeDelta ||
                uiView.region.span.longitudeDelta != coordinateRegion.span.longitudeDelta {
                uiView.setRegion(coordinateRegion, animated: true)
            }
        }

        // Загружаем метки из памяти устройства и отображаем их на карте
        loadMarkersFromUserDefaults()
        displayMarkersOnMap(uiView: uiView)

        // Обновляем маркеры только если это необходимо
        if shouldUpdateMarkers {
            let lat = userLocation.latitude
            let lon = userLocation.longitude

            if lat != 0.0 && lon != 0.0 {
                fetchMarkers(urlString: "https://meetmap.up.railway.app/get/public/mark/\(uid)/\(lat)/\(lon)") { fetchedMarkers in
                    DispatchQueue.main.async {
                        // Сохраняем уникальные маркеры
                        storeUniqueMarkers(fetchedMarkers)
                        // Загружаем метки из памяти устройства
                        loadMarkersFromUserDefaults()
                        // Обновляем отображение меток на карте
                        displayMarkersOnMap(uiView: uiView)
                    }
                }
            }
        }

        // Сбрасываем флаг, чтобы в следующий раз обновление маркеров происходило только при значительных изменениях
        shouldUpdateMarkers = true
    }

    func displayMarkersOnMap(uiView: MKMapView) {
        // Очистка старых аннотаций и оверлеев
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)

        // Добавление только новых меток
        for markerData in markers {
            let annotation = CustomAnnotation(id: markerData.id)
            annotation.coordinate = markerData.locationCoordinate2D
            annotation.title = markerData.name
            annotation.subtitle = """
                \(markerData.whatHappens)
                ID: \(markerData.id)
                From: \(markerData.startDate)
                To: \(markerData.endDate)
                People: \(markerData.participants)
                Access: \(markerData.access ? "Public" : "Private")
                """
            uiView.addAnnotation(annotation)

            let circle = MKCircle(center: markerData.locationCoordinate2D, radius: CLLocationDistance(markerData.participants))
            uiView.addOverlay(circle)
        }
    }







        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, MKMapViewDelegate {
            var parent: CustomMapView

            init(_ parent: CustomMapView) {
                self.parent = parent
            }

         




            @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
                if gestureRecognizer.state == .began {
                    guard let mapView = gestureRecognizer.view as? MKMapView else { return }
                    let location = gestureRecognizer.location(in: mapView)
                    let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                    
                    // Найти текущий UIViewController
                    guard let viewController = UIApplication.shared.keyWindow?.rootViewController else { return }
                    
                    // Создать SwiftUI view с помощью UIHostingController
                    let alertHelperView = AlertHelperView(
                        markerStore: parent.markerStore,
                        coordinate: coordinate,
                        uid: self.parent.uid, // Используйте правильное имя параметра
                        key: self.parent.key, // Используйте правильное имя параметра
                        completion: { newAnnotation, radius in
                            mapView.addAnnotation(newAnnotation)
                            
                            // Пример использования значения радиуса:
                            let circle = MKCircle(center: coordinate, radius: radius)
                            mapView.addOverlay(circle)
                            
                            // Отключить обновление карты при изменении региона после добавления метки
                            self.parent.isMapTypeChanged = true
                            self.parent.shouldUpdateMarkers = false
                            
                            let distance = CLLocationDistance(hypot(coordinate.latitude - mapView.region.center.latitude, coordinate.longitude - mapView.region.center.longitude))
                            if distance > 0.01 {
                                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                                mapView.setRegion(region, animated: true)
                            }
                        }
                    )
                    
                    let hostingController = UIHostingController(rootView: alertHelperView)
                    
                    // Презентовать UIHostingController как модальный контроллер
                    viewController.present(hostingController, animated: true, completion: nil)
                }
            }


            
            func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
                guard let annotation = view.annotation as? CustomAnnotation else { return }
                
                // Получите данные маркера по его UUID
                if let markerData = parent.markerStore.markers.first(where: { $0.id == annotation.id }) {
                    // Найти текущий UIViewController
                    guard let viewController = UIApplication.shared.windows.first?.rootViewController else { return }

                    // Создать SwiftUI view с помощью UIHostingController
                    let dataMarkView = DataMarkView(id: markerData.id, markerStore: parent.markerStore)
                    let hostingController = UIHostingController(rootView: dataMarkView)

                    viewController.present(hostingController, animated: true, completion: nil)
                }
            }


    }
}
