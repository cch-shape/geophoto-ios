//
//  GeoPhotoApp.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {

}

@main
struct GeoPhotoApp: App {
    @StateObject private var settings = SettingsModel()
    @StateObject private var authentication = BiometricModel()
    @StateObject private var user = UserModel()
    
    var body: some Scene {
        WindowGroup {
            Router(GuardView: GuardView(), ProtectedView: ContentView())
                .environmentObject(settings)
                .environmentObject(authentication)
                .environmentObject(user)
                .preferredColorScheme(settings.preferredTheme)
        }
    }
}
