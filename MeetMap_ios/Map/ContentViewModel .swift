//
//  Maplogeck.swift
//  MeetMap_ios
//
//  Created by Ilya Prokofev on 27.07.2024.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

import Foundation
import SwiftUI
import MapKit

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 33.4, longitude: -117.4), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    @Published var address = ""
    @Published var location = CLLocation(latitude: 0, longitude: 0)

    private var lastResolved = CLLocation()
    private var locationManager = CLLocationManager()
    
    private var userManuallyMovedMap = false
    // Новое свойство для отслеживания, переместил ли пользователь карту вручную.

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        } else {
            print("Location services are off. Turn them on in settings.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }

        if last.distance(from: lastResolved) > 10 {
            resolveLocationName(with: last) { address in
                DispatchQueue.main.async {
                    self.address = address
                    self.lastResolved = last
                }
            }
        }

        DispatchQueue.main.async {
            self.location = last
            if !self.userManuallyMovedMap {
                self.region = MKCoordinateRegion(center: last.coordinate, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
            }
        }
    }

    func resolveLocationName(with location: CLLocation, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { placemarks, error in
            guard let place = placemarks?.first, error == nil else {
                completion("")
                return
            }

            var name = ""
            if let locality = place.subThoroughfare {
                name += locality
            }
            if let street = place.thoroughfare {
                name += " \(street)"
            }
            if let city = place.locality {
                name += " \(city)"
            }
            if let adminRegion = place.administrativeArea {
                name += ", \(adminRegion)"
            }
            if let zipCode = place.postalCode {
                name += " \(zipCode)"
            }

            completion(name)
        }
    }
    
    


    private func checkLocationAuth() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location is restricted")
        case .denied:
            print("Location is denied in settings for this app")
        case .authorizedAlways, .authorizedWhenInUse:
            if let location = locationManager.location {
                self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.location = location
            }
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }

    func updateAddress() {
        guard let location = locationManager.location else { return }
        resolveLocationName(with: location) { address in
            DispatchQueue.main.async {
                self.address = address
            }
        }
    }
    
    func mapUserManuallyMoved() {
        // Метод для установки флага, что пользователь переместил карту вручную.
        self.userManuallyMovedMap = true
    }

    func mapUserReset() {
        // Метод для сброса флага перемещения карты пользователем.
        self.userManuallyMovedMap = false
    }
}



