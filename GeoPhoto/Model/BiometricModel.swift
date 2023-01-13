//
//  AuthenticationModel.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import Foundation
import LocalAuthentication

final class BiometricModel: ObservableObject {
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
    
    func Prompt(callback: @escaping (Bool) -> Void = { _ in }, message: String = "Unlock the App") {
        guard biometryType != "" else {
            isAuthenticated = true
            return
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: message,
            reply: { success, error in
                guard error == nil else {
                    print(error!.localizedDescription)
                    callback(success)
                    return
                }
                
                DispatchQueue.main.async() {
                    self.isAuthenticated = true
                    self.authenticatedAt = Date.now
                    self.context = LAContext()
                    callback(success)
                }
            }
        )
    }
    
    func checkAppLockTimeout(appLockTimeOut: Double) {
        if abs(authenticatedAt.timeIntervalSinceNow) >= appLockTimeOut {
            isAuthenticated = false
        }
    }
}
