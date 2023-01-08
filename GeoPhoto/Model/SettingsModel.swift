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
    @AppStorage("appLockEnabled") var appLockEnabled = false
    @AppStorage("appLockTimeout") var appLockTimeout = 15.0
}
