//
//  MarkerData.swift
//  MeetMap_ios
//
//  Created by Ilya Prokofev on 29.07.2024.
//

import Foundation
import MapKit
import CoreLocation

// Вспомогательная структура для представления координат
struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var locationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// Структура данных для метки
struct MarkerData: Codable {
    let position: Coordinate
    let name: String
    let whatHappens: String
    let startDate: Date?
    let endDate: Date?
    let participants: Int
    let access: Bool
    
    // Инициализатор для создания MarkerData из CLLocationCoordinate2D
    init(position: CLLocationCoordinate2D, name: String, whatHappens: String, startDate: Date?, endDate: Date?, participants: Int, access: Bool) {
        self.position = Coordinate(position)
        self.name = name
        self.whatHappens = whatHappens
        self.startDate = startDate
        self.endDate = endDate
        self.participants = participants
        self.access = access
    }
    
    // Получение CLLocationCoordinate2D из MarkerData
    var coordinate: CLLocationCoordinate2D {
        return position.locationCoordinate2D
    }
}
