//
//  MyPhoto.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI
import CoreLocation
import Contacts

struct MyPhoto: View {
    @State private var isCreating = false
    @StateObject var locationModel = LocationModel()
    var locationSelection = LocationSelectionModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Gallery()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if locationModel.locationManager.authorizationStatus != .authorizedWhenInUse ||
                            locationModel.locationManager.location == nil {
                            isCreating = true
                            return
                        }
                        guard let location = locationModel.locationManager.location else {return}
                        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                            guard let placemark = placemarks?.first else { return }
                            let formatter = CNPostalAddressFormatter()
                            let address = formatter.string(from: placemark.postalAddress!).split(separator: "\n").reversed().joined(separator: ", ")
                            locationSelection.selected.address = address
                            locationSelection.selected.coordinate = location.coordinate
                            isCreating = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationBarTitle("My Photo")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isCreating) {
                NewPhotoForm(locationSelection: locationSelection)
                    .environmentObject(locationModel)
            }
        }
    }
}

struct MyPhoto_Previews: PreviewProvider {
    static var previews: some View {
        MyPhoto()
    }
}
