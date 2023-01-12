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
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var description: String = ""
    @State private var region = MKCoordinateRegion()
    private var selectedLocation: CLLocationCoordinate2D {
        region.center
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("About this photo...", text: $description)
                    .padding()
                .listRowInsets(EdgeInsets())
                Section("Photo") {
                    ImagePickerCard()
//                        .padding()
                }
                .listRowInsets(EdgeInsets())
                Section("Location") {
                    LocationPicker(region: $region)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            .navigationBarTitle("New Photo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NewPhotoForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPhotoForm()
    }
}
