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

import SwiftUI
import MapKit
import Combine

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion()
    @Published var address = ""
    @Published var location = CLLocation(latitude: 0, longitude: 0)
    @Published var userCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    // Добавлено для отслеживания необходимости обновления маркеров
    @Published var shouldUpdateMarkers = false

    private var lastResolved = CLLocation()
    private var locationManager = CLLocationManager()
    private var userManuallyMovedMap = false
    
    private var lastRequestTime: Date?
    private let minimumDistance: CLLocationDistance = 50 // 50 meters
    private let minimumTimeInterval: TimeInterval = 60 // 30 seconds

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkIfLocationServicesIsEnabled()
    }

    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            print("Location services are off. Turn them on in settings.")
        }
    }

    
        // обновляет мето пложение

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }

        let now = Date()
        let timeInterval = lastRequestTime == nil ? minimumTimeInterval : now.timeIntervalSince(lastRequestTime!)
        let distance = lastLocation.distance(from: lastResolved)

        if distance > minimumDistance || timeInterval >= minimumTimeInterval {
            lastRequestTime = now
            lastResolved = lastLocation

            DispatchQueue.main.async {
                self.location = lastLocation
                self.userCoordinate = lastLocation.coordinate
                if !self.userManuallyMovedMap {
                    self.region = MKCoordinateRegion(center: lastLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                }
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
    
    
}


