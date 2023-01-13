//
//  MyPhoto.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI
import CoreLocation
import Contacts
import MapKit

struct MyPhoto: View {
    @State var isCreating = false
    @StateObject var locationModel = LocationModel()
    @EnvironmentObject var photoData: PhotoData
    var locationSelection = LocationSelectionModel()
    enum imageSize: Int {
        case large = 1
        case medium = 2
        case small = 3
    }
    @State private var selectedSize: imageSize = .medium
    @State private var selectedPhoto: PhotoModel? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: selectedSize.rawValue)) {
                        ForEach(photoData.photos) { p in
                            GeometryReader { reader in
                                Button {
                                    selectedPhoto = p
                                } label: {
                                    PhotoCard(
                                        size: reader.size.width,
                                              url: selectedSize == .large ? p.thumbnail_url_2x : p.thumbnail_url_1x
                                    )
                                }
                                .sheet(item: $selectedPhoto) { p in
                                    PhotoForm(
                                        photo: $selectedPhoto,
                                        region: MKCoordinateRegion(
                                            center: p.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        )
                                    )
                                    .environmentObject(photoData)
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    .padding()
                }
                    .environmentObject(photoData)
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
                ToolbarItem(placement: .bottomBar) {
                    Picker("Image Size", selection: $selectedSize) {
                        Text("Small").tag(imageSize.small)
                        Text("Medium").tag(imageSize.medium)
                        Text("Large").tag(imageSize.large)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationBarTitle("My Photo")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isCreating) {
                NewPhotoForm(isPresent: $isCreating, locationSelection: locationSelection)
                    .environmentObject(locationModel)
            }
            .onReceive(photoData.$isLoading, perform: { isLoading in
                if !isLoading {
                    isCreating = false
                }
            })
        }
    }
}

struct MyPhoto_Previews: PreviewProvider {
    static var previews: some View {
        MyPhoto()
            .environmentObject(PhotoData())
    }
}
