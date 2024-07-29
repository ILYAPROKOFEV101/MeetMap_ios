//
//  Map.swift
//  MeetMap_ios
//
//  Created by Ilya Prokofev on 25.07.2024.
//
// English or Spanish 


// Представление карты
import SwiftUI
import MapKit
import CoreLocation

import Foundation
import CoreLocation
import MapKit


struct ContentViewtwo: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showAddress: Bool = false
    @State private var userAnnotations: [MKPointAnnotation] = []
    @State private var userAnnotation = MKPointAnnotation()
    @StateObject private var markerStore = MarkerStore()
    @State private var mapType: MKMapType = .standard
    var body: some View {
        ZStack(alignment: .bottom) {
            CustomMapView(coordinateRegion: $viewModel.region, mapType: $mapType,  markerStore: markerStore)
                .onAppear {
                    viewModel.checkIfLocationServicesIsEnabled()
                }
                .edgesIgnoringSafeArea(.all)

            VStack {
                TextField("Enter address", text: $viewModel.address, onCommit: {
                    withAnimation {
                        showAddress = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        withAnimation {
                            showAddress = false
                        }
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                if showAddress {
                    Text(viewModel.address)
                        .padding()
                        .background(Color.yellow)
                        .transition(.opacity)
                }

                Spacer()

                HStack {
                    Button(action: {
                        viewModel.updateAddress()
                      
                    }) {
                        Image(systemName: "location.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .padding()
                    }

                    Button(action: {
                        mapType = (mapType == .standard) ? .satellite : .standard
                    }) {
                        Image(systemName:  "globe")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .padding()
                    }
                }
            }
        }
    }

}




// Превью для Canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewtwo()
    }
}

