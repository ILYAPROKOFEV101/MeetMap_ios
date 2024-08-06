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
import GoogleSignIn
import SDWebImageSwiftUI
import _MapKit_SwiftUI


struct ContentViewtwo: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showAddress: Bool = false
    @State private var userAnnotations: [MKPointAnnotation] = []
    @State private var userAnnotation = MKPointAnnotation()
    @StateObject private var markerStore = MarkerStore()
    @State private var mapType: MKMapType = .standard
    @State private var userName: String = ""
    @State private var userProfileImageURL: URL? = nil
    @State private var isUserSignedIn: Bool = false
    @State private var userUID: String = ""
    @State private var savedResponse: String = ""
    private var lastResolved = CLLocation()

    var body: some View {
        ZStack(alignment: .bottom) {
            
                CustomMapView(
                    coordinateRegion: $viewModel.region,
                    mapType: $mapType,
                    markerStore: markerStore,
                    uid: $userUID,
                    key: $savedResponse,
                    userLocation: $viewModel.userCoordinate
                )
                .onAppear {
                    if let response = UserDefaults.standard.string(forKey: "responseKey") {
                        savedResponse = response
                       
                    }
                  
                    
                    print("Saved Response: \(savedResponse)")
                    
                    let userInfo = FirebAuth.share.getCurrentUserInfo()
                    if let uid = userInfo.uid, !uid.isEmpty {
                        userUID = uid
                        if let name = userInfo.name {
                            userName = name
                        }
                        if let profileImageURL = userInfo.profileImageURL {
                            userProfileImageURL = profileImageURL
                        }
                    }
                
                    // Пример использования
                    checkUser(uid: userUID) { key in
                        if let key = key {
                           savedResponse = key
                            // Используйте ключ, если он существует
                            print("Retrieved Key: \(key)")
                        } else {
                            // Ключ не был найден
                            print("Failed to retrieve key.")
                        }
                    }
                    
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
                        Image(systemName: "globe")
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

