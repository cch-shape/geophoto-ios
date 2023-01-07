//
//  ContentView.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
