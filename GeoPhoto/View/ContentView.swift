//
//  ContentView.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI

struct ContentView: View {
    @State var selection = 1
    @EnvironmentObject var settings: SettingsModel
    @EnvironmentObject var authentication: AuthenticationModel
    
    var body: some View {
        TabView(selection: $selection) {
            Home()
                .badge(0)
                .tabItem{
                    Label("Home", systemImage: "house")
                }
            MyPhoto()
                .badge(0)
                .tabItem{
                    Label("MyPhoto", systemImage: "photo.fill.on.rectangle.fill")
                }
            PhotoMap()
                .badge(0)
                .tabItem{
                    Label("Map", systemImage: "pin.circle")
                }
            Friends()
                .badge(0)
                .tabItem{
                    Label("Friends", systemImage: "person.2")
                }
            Settings()
                .badge(0)
                .tabItem{
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
            .environmentObject(SettingsModel())
            .environmentObject(AuthenticationModel())
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            .previewDisplayName("iPhone SE")
            .environmentObject(SettingsModel())
            .environmentObject(AuthenticationModel())
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPad (10th generation)"))
            .previewDisplayName("iPad")
            .environmentObject(SettingsModel())
            .environmentObject(AuthenticationModel())
    }
}
