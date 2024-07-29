//
//  MarkerStore.swift
//  MeetMap_ios
//
//  Created by Ilya Prokofev on 29.07.2024.
//

import Foundation
import MapKit


class MarkerStore: ObservableObject {
    @Published var markers: [MarkerData] = [] {
        didSet {
            saveMarkers()
        }
    }
    
    init() {
        loadMarkers()
    }
    
    func addMarker(_ marker: MarkerData) {
        markers.append(marker)
    }
    
    func getMarkers() -> [MarkerData] {
        return markers
    }
    
    private func saveMarkers() {
        do {
            let data = try JSONEncoder().encode(markers)
            let url = getDocumentsDirectory().appendingPathComponent("markers.json")
            try data.write(to: url)
        } catch {
            print("Error saving markers: \(error)")
        }
    }
    
    private func loadMarkers() {
        let url = getDocumentsDirectory().appendingPathComponent("markers.json")
        if let data = try? Data(contentsOf: url) {
            do {
                markers = try JSONDecoder().decode([MarkerData].self, from: data)
            } catch {
                print("Error loading markers: \(error)")
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

