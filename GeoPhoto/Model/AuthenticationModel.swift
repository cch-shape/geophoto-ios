//
//  AuthenticationModel.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import Foundation
import LocalAuthentication

@MainActor
final class AuthenticationModel: ObservableObject {
    var context = LAContext()
    var biometryType: String
    var authenticatedAt = Date.distantPast
    @Published var isAuthenticated = false
    
    init() {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            biometryType = ""
            return
        }
        
        switch context.biometryType {
        case .touchID:
            biometryType = "Touch ID"
        case .faceID:
            biometryType = "Face ID"
        default:
            biometryType = "Pin"
        }
    }
    
    func Prompt() {
        guard biometryType != "" else {
            isAuthenticated = true
            return
        }
        
        Task {
            do {
                try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock the App")
                isAuthenticated = true
                authenticatedAt = Date.now
                context = LAContext()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func checkAppLockTimeout(appLockTimeOut: Double) {
        print("c")
        print(abs(authenticatedAt.timeIntervalSinceNow), appLockTimeOut)
        if abs(authenticatedAt.timeIntervalSinceNow) >= appLockTimeOut {
            isAuthenticated = false
        }
    }
}
