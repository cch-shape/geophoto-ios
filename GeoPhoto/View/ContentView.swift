//
//  ContentView.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var photoData = PhotoData()
    @EnvironmentObject var settings: SettingsModel
    @EnvironmentObject var authentication: BiometricModel
    @EnvironmentObject var user: UserModel
    
    var body: some View {
        TabView() {
//            Home()
//                .badge(0)
//                .tabItem{
//                    Label("Home", systemImage: "house")
//                }
//                .environmentObject(user)
            MyPhoto()
                .badge(0)
                .tabItem{
                    Label("My Photo", systemImage: "photo.fill.on.rectangle.fill")
                }
                .environmentObject(photoData)
            PhotoMap()
                .badge(0)
                .tabItem{
                    Label("Map", systemImage: "pin.circle")
                }
                .environmentObject(photoData)
//            Friends()
//                .badge(0)
//                .tabItem{
//                    Label("Friends", systemImage: "person.2")
//                }
            Settings()
                .badge(0)
                .tabItem{
                    Label("Settings", systemImage: "gearshape")
                }
                .environmentObject(user)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
            .environmentObject(SettingsModel())
            .environmentObject(BiometricModel())
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            .previewDisplayName("iPhone SE")
            .environmentObject(SettingsModel())
            .environmentObject(BiometricModel())
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPad (10th generation)"))
            .previewDisplayName("iPad")
            .environmentObject(SettingsModel())
            .environmentObject(BiometricModel())
    }
}
