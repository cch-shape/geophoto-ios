//
//  NewPhotoForm.swift.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 12/1/2023.
//

import SwiftUI
import PhotosUI
import MapKit

struct NewPhotoForm: View {
    @State private var selectedImage: UIImage? = nil
    @State private var description: String = ""
    @StateObject var locationModel = LocationModel()
    @StateObject var locationSelection: LocationSelectionModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("About") {
                    TextField("About this photo...", text: $description)
                        .padding()
                }
                .listRowInsets(EdgeInsets())
                Section("Photo") {
                    ImagePickerCard(selectedImage: $selectedImage)
                }
                .listRowInsets(EdgeInsets())
                Section("Location") {
                    LocationPicker(
                        region: MKCoordinateRegion(
                            center: locationModel.locationManager.location?.coordinate ??
                            CLLocationCoordinate2D(latitude: 1, longitude: 1),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ),
                        searchMode: locationModel.locationManager.authorizationStatus != .authorizedWhenInUse,
                        locationSelection: locationSelection
                    )
                        .environmentObject(locationModel)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        print("submit")
                    }.disabled(false)
                }

            }
            .navigationBarTitle("New Photo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NewPhotoForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPhotoForm(locationSelection: LocationSelectionModel(), locationModel: LocationModel())
    }
}
