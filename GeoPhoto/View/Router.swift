//
//  Router.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 9/1/2023.
//

import SwiftUI

struct Router: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var settings: SettingsModel
    @EnvironmentObject var authentication: BiometricModel
    @EnvironmentObject var user: UserModel
    
    var GuardView: GuardView
    var ProtectedView: ContentView
    
    var body: some View {
        if user.authorizationStatus != UserModel.AuthorizationStatus.loggedIn {
            LoginView()
                .environmentObject(user)
        } else if settings.appLockEnabled && !authentication.isAuthenticated {
            GuardView
                .environmentObject(authentication)
                .onChange(of: scenePhase) { phase in
                    if phase == .active
                    {
                        authentication.Prompt()
                    }
                }
        } else {
            ProtectedView
                .environmentObject(settings)
                .environmentObject(authentication)
                .environmentObject(user)
                .onChange(of: scenePhase) { phase in
                    if settings.appLockEnabled && phase == .inactive
                    {
                        authentication.checkAppLockTimeout(appLockTimeOut: settings.appLockTimeout)
                    }
                }
        }
    }
}
