//
//  Alert_Dealog.swift
//  MeetMap_ios
//
//  Created by Ilya Prokofev on 28.07.2024.
//

import MapKit
import SwiftUI


import SwiftUI
import MapKit

struct AlertHelperView: View {
    @ObservedObject var markerStore: MarkerStore
    let coordinate: CLLocationCoordinate2D
    var completion: (MKPointAnnotation, Double) -> Void
    
    // Прочие состояния и элементы UI
    @State private var markerName = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var radius: Double = 100
    @State private var isPublic = false
    @State private var access = "public" // Переменная для доступа, инициализированная по умолчанию
    
    var body: some View {
        VStack {
            VStack {
                Text("Enter details for the marker").font(.headline.bold())
                Spacer()
                TextField("Marker name", text: $markerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer().frame(height: 30)
                
                TextField("Description", text: $description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                VStack {
                    DatePicker("Start date and time", selection: $startDate)
                        .datePickerStyle(CompactDatePickerStyle())
                        .frame(height: 70)
                    Spacer().frame(height: 20)
                    
                    DatePicker("End date and time", selection: $endDate)
                        .datePickerStyle(CompactDatePickerStyle())
                        .frame(height: 70)
                }
                               
                Spacer().frame(height: 30)
                
                Slider(value: $radius, in: 2...100, step: 1) {
                    
                }
                Text("People: \(Int(radius)) ")
               
                Spacer().frame(height: 30)
                
                // Toggle для выбора состояния метки
                Toggle(isOn: $isPublic) {
                    Text("Make marker " + access)
                }
                .onChange(of: isPublic) { newValue in
                    // Обновляем значение переменной access в зависимости от состояния Toggle
                    access = newValue ? "private" : "public"
                }
                
                Spacer().frame(height: 30)
                
                HStack {
                    Button("Cancel") {
                        // Действие при отмене
                    }.font(.headline) // Пример использования предустановленного стиля шрифта
                    
                    Spacer()
                    Button("Add") {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = markerName
                        annotation.subtitle = """
                        \(description)
                        From: \(startDate)
                        To: \(endDate)
                        People: \(Int(radius))
                        Access: \(isPublic ? "Public" : "Private")
                        """
                        
                        // Создание объекта MarkerData и добавление его в список
                        let markerData = MarkerData(
                            position: coordinate,
                            name: markerName,
                            whatHappens: description,
                            startDate: startDate,
                            endDate: endDate,
                            participants: Int(radius),
                            access: isPublic
                        )
                                               
                        markerStore.addMarker(markerData)
                        
                        // Использование completion для добавления аннотации на карту
                        completion(annotation, radius)
                    }.font(.headline) // Пример использования предустановленного стиля шрифта
                }
                .padding()
            }
            .padding()
        }
    }
}



