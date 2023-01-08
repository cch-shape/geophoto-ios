//
//  Settings.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject var settings: SettingsModel
    @EnvironmentObject var authentication: AuthenticationModel
    
    var body: some View {
        NavigationView {
            Form {
                if !authentication.biometryType.isEmpty {
                    Section(
                        header: Text("Security"),
                        footer: Text("Use \(authentication.biometryType) to unlock this App")
                    ){
                        Toggle("Enable App Lock", isOn: $settings.appLockEnabled)
                            .onChange(of: settings.appLockEnabled, perform: { _ in
                                authentication.isAuthenticated = true
                            })
                        if settings.appLockEnabled {
                            Picker("App Lock Timeout", selection: $settings.appLockTimeout) {
                                Text("Instant").tag(0.0)
                                Text("5 minutes").tag(300.0)
                                Text("10 minutes").tag(600.0)
                                Text("15 minutes").tag(900.0)
                                Text("30 minutes").tag(1800.0)
                                Text("1 hour").tag(3600.0)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Settings")
            .pickerStyle(.navigationLink)
            
        }
    }
}
