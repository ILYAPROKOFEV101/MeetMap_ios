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
    @State private var isMapTypeChanged = false

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.mapType = mapType

        // Добавляем распознаватель долгого нажатия
              let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress(_:)))
              mapView.addGestureRecognizer(longPressGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if uiView.mapType != mapType {
            uiView.mapType = mapType
            isMapTypeChanged = true
        }

        if !isMapTypeChanged {
            // Обновляем только если координаты региона изменились
            if uiView.region.center.latitude != coordinateRegion.center.latitude ||
               uiView.region.center.longitude != coordinateRegion.center.longitude ||
               uiView.region.span.latitudeDelta != coordinateRegion.span.latitudeDelta ||
               uiView.region.span.longitudeDelta != coordinateRegion.span.longitudeDelta {
                uiView.setRegion(coordinateRegion, animated: true)
            }
        } else {
            isMapTypeChanged = false
        }

        // Удаляем старые аннотации
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)

        // Добавляем новые аннотации и круги из markerStore
                for markerData in markerStore.markers {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = markerData.coordinate
                    annotation.title = markerData.name
                    annotation.subtitle = """
                    \(markerData.whatHappens)
                    From: \(markerData.startDate ?? Date())
                    To: \(markerData.endDate ?? Date())
                    People: \(markerData.participants)
                    Access: \(markerData.access ? "Public" : "Private")
                    """
                    uiView.addAnnotation(annotation)

                    let circle = MKCircle(center: markerData.coordinate, radius: CLLocationDistance(markerData.participants))
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
                        let alertHelperView = AlertHelperView(markerStore: parent.markerStore, coordinate: coordinate) { newAnnotation, radius in
                            mapView.addAnnotation(newAnnotation)
                            
                            // Пример использования значения радиуса:
                            let circle = MKCircle(center: coordinate, radius: radius)
                            mapView.addOverlay(circle)
                            
                            let distance = CLLocationDistance(hypot(coordinate.latitude - mapView.region.center.latitude, coordinate.longitude - mapView.region.center.longitude))
                            if distance > 0.01 {
                                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                                mapView.setRegion(region, animated: true)
                            }
                        }
                        let hostingController = UIHostingController(rootView: alertHelperView)
                        
                        // Презентовать UIHostingController как модальный контроллер
                        viewController.present(hostingController, animated: true, completion: nil)
                    }
                }

        // Дополнительные методы MKMapViewDelegate, если необходимо
    }
}
