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
    
    // Wrapping "Enable App Lock" setting into computed property
    // so an authentication request can be prompted before enabling
    private var appLockEnableBindWrapper: Binding<Bool> { Binding (
        get: { self.settings.appLockEnabled },
        set: { v in
            if v {
                authentication.Prompt(
                    callback: { success in
                        if success {
                            DispatchQueue.main.async(){
                                self.settings.appLockEnabled = true
                            }
                        }
                    },
                    message: "Enable App Lock"
                )
            } else {
                self.settings.appLockEnabled = false
                self.authentication.isAuthenticated = false
            }
        }
    )}
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $settings.theme) {
                        ForEach(SettingsModel.Theme.allCases) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                }
                if !authentication.biometryType.isEmpty {
                    Section(
                        header: Text("Security"),
                        footer: Text("Use \(authentication.biometryType) to unlock this App")
                    ){
                        Toggle("Enable App Lock", isOn: appLockEnableBindWrapper)
                        if settings.appLockEnabled {
                            Picker("App Lock Timeout", selection: $settings.appLockTimeout) {
                                Text("Instant").tag(0.0)
                                Text("1 minute").tag(60.0)
                                Text("5 minutes").tag(300.0)
                                Text("10 minutes").tag(600.0)
                                Text("15 minutes").tag(900.0)
                                Text("30 minutes").tag(1800.0)
                                Text("1 hour").tag(3600.0)
                            }
                        }
                    }
                }
                Section(header: Text("Privacy")) {
                    Toggle("Upload Photo by Default", isOn: $settings.uploadPhotoByDefault)
                    Picker("Default Photo Visibility", selection: $settings.defaultPhotoVisibility) {
                        ForEach(SettingsModel.PhotoVisibility.allCases) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    NavigationLink("Visibility Groups", destination: VisibilityGroup())
                }
            }
            .navigationBarTitle("Settings")
            .pickerStyle(.navigationLink)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
            .environmentObject(SettingsModel())
            .environmentObject(AuthenticationModel())
    }
}
