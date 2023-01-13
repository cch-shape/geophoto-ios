//
//  NewPhotoForm.swift.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 12/1/2023.
//

import SwiftUI
import PhotosUI
import MapKit

struct PhotoForm: View {
    @StateObject var locationModel = LocationModel()
    @Binding var photo: Photo?
    @State var region: MKCoordinateRegion
    @State var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            if let photo {
                ScrollView {
                    VStack {
                        AsyncImage(url: photo.thumbnail_url_2x) { img in
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                        
                        //                    VStack {
                        ZStack {
                            Map(
                                coordinateRegion: $region,
                                showsUserLocation: true,
                                annotationItems: [photo]
                            ) { item in
                                MapAnnotation(coordinate: photo.coordinate) {
                                    AsyncImage(url: photo.thumbnail_url_1x) { img in
                                        img
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(10)
                                    .shadow(radius: 4)
                                }
                            }
                            .cornerRadius(10)
                            .aspectRatio(1.4, contentMode: .fill)
                            
                            HStack {
                                Spacer()
                                VStack {
                                    Button(action: {
                                        guard let loc = locationModel.locationManager.location else { return }
                                        withAnimation {
                                            region = MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                                        }
                                    }) {
                                        Image(systemName: "location.fill")
                                            .renderingMode(.original)
                                            .padding()
                                            .background(.background)
                                    }
                                    .clipShape(Circle())
                                    
                                    Button(action: {
                                        withAnimation {
                                            region = MKCoordinateRegion(center: photo.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                                        }
                                    }) {
                                        Image(systemName: "photo.fill")
                                            .renderingMode(.original)
                                            .padding()
                                            .background(.background)
                                    }
                                    .clipShape(Circle())
                                    Spacer()
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 6)
                        }
                        .padding(.horizontal)
                        
                        Section {
                            Text(photo.address_name ?? "")
                                .font(.footnote)
                                .bold()
                                .padding(.vertical, 4)
                            Text(photo.address ?? "")
                                .font(.footnote)
                        }
                        
                        Button{
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Photo")
                                Spacer()
                            }
                        }
                        .buttonStyle(.bordered)
                        .padding()
                        .alert("Are you sure?", isPresented: $showDeleteAlert) {
                            Button("Delete", role: .destructive) {
                                
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                        .foregroundColor(.red)
                    }
                }
                .navigationBarTitle(photo.description == nil || photo.description == "" ? "No Title" : photo.description!)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            self.photo = nil
                        }
                    }
                }
            }
        }
    }
}
