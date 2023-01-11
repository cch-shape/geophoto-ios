//
//  LocationManager.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 11/1/2023.
//

import Foundation
import CoreLocation

class LocationModel : NSObject, CLLocationManagerDelegate, ObservableObject {
    var locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
