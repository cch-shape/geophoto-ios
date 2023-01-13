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
    @Binding var isPresent: Bool
    @State private var selectedImage: UIImage? = nil
    @State private var description: String = ""
    @StateObject var locationModel = LocationModel()
    @StateObject var locationSelection: LocationSelectionModel
    @EnvironmentObject var photoData: PhotoData
    
    var body: some View {
        NavigationStack {
            ZStack {
                if photoData.isLoading {
                    ProgressView()
                } else {
                    Form {
                        Section("About") {
                            TextField("About this photo...", text: $description)
                                .padding()
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Photo*") {
                            ImagePickerCard(selectedImage: $selectedImage)
                                .environmentObject(photoData)
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
                            .environmentObject(photoData)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                guard let img = selectedImage else {
                                    return
                                }
                                photoData.post(description: description, image: img, lsmo: locationSelection.selected)
                            }.disabled(selectedImage == nil)
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                isPresent = false
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("New Photo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
