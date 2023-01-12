//
//  LocationQueryResult.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 12/1/2023.
//

import Foundation
import CoreLocation

class LocationQueryResult: ObservableObject{
    struct Option: Identifiable {
        let id = UUID()
        var name: String
        var address: String
        var coordinate: CLLocationCoordinate2D
    }
    
    @Published var options: [Option] = []
    @Published var showQueryResult = false
    @Published var selected: Option = Option(name: "", address: "", coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 1))
    
    func append(name: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.options.append(Option(name: name, address: address, coordinate: coordinate))
    }
    
    func show() {
        if !self.options.isEmpty {
            showQueryResult = true
        }
    }
    
    func dismiss() {
        self.options.removeAll()
        showQueryResult = false
    }
    
    func select(_ opt: Option) {
        self.selected = opt
        dismiss()
    }
}
