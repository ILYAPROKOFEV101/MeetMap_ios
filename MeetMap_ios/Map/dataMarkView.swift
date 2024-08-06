//
//  dataMarkView.swift
//  MeetMap_ios
//
//  Created by Ilya Prokofev on 30.07.2024.
//

import SwiftUI

import SwiftUI

import SwiftUI

struct DataMarkView: View {
    let id: String
    @ObservedObject var markerStore: MarkerStore
    var markerData: MarkerData? {
        markerStore.markers.first { $0.id == id }
    }
    
    var body: some View {
        VStack {
            if let markerData = markerData {
                Text("Marker Name: \(markerData.name)")
                    .font(.title)
                Text("What Happens: \(markerData.whatHappens)")
                    .font(.subheadline)
                
                if let startDate = formattedDate(from: markerData.startDate) {
                    Text("Start Date: \(startDate, formatter: dateFormatter)")
                        .font(.subheadline)
                } else {
                    Text("Start Date: Not Available")
                        .font(.subheadline)
                }
                
                if let endDate = formattedDate(from: markerData.endDate) {
                    Text("End Date: \(endDate, formatter: dateFormatter)")
                        .font(.subheadline)
                } else {
                    Text("End Date: Not Available")
                        .font(.subheadline)
                }
                
                Text("Participants: \(markerData.participants)")
                    .font(.subheadline)
                Text("Access: \(markerData.access ? "Public" : "Private")")
                    .font(.subheadline)
            } else {
                Text("Marker not found")
                    .font(.headline)
            }
        }
        .padding()
    }
    
    private func formattedDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Задайте формат даты, соответствующий вашему `startDate` и `endDate`
        return formatter.date(from: dateString)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    DataMarkView(id: "sample-id", markerStore: MarkerStore()) // Пример ID
}




import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var id: String

    init(id: String) {
        self.id = id
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0) // Установите начальные значения
        super.init()
    }
}

