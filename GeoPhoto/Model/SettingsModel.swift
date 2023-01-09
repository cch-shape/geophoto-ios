//
//  SettingsModel.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import Foundation
import Combine
import SwiftUI

final class SettingsModel: ObservableObject {
    enum Theme: String, CaseIterable, Identifiable {
        case System, Light, Dark
        var id: Theme { self }
    }
    @AppStorage("theme") var theme = Theme.System
    var preferredTheme: ColorScheme? {
        switch theme {
        case .Light:
            return .light
        case .Dark:
            return .dark
        default:
            return nil
        }
    }
    @AppStorage("appLockEnabled") var appLockEnabled = false
    @AppStorage("appLockTimeout") var appLockTimeout = 15.0
    enum PhotoVisibility: String, CaseIterable, Identifiable {
        case Private, Friends, Groups
        var id: PhotoVisibility { self }
    }
}
