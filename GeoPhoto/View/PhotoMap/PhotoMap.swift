//
//  MapView.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI
import MapKit
import CoreLocation

struct PhotoMap: View {
    @EnvironmentObject var photoData: PhotoData
    @StateObject var lm = LocationModel()
    @State private var region = MKCoordinateRegion()
    @State private var showLocationOffAlert = false
    @State private var showLocationDeinedAlert = false
//    @State var photo = Photo(uuid: "577ccbb0-91b5-11ed-91d1-0242c0a86002", user_id: 0, description: "testing photo2", timestamp: "2023-01-11T13:39:16Z", photo_url: "http://192.168.128.75:3030/static/image/04369ed0-9191-11ed-a25d-0242c0a82002/pepe.png", latitude: 22.35268, longitude: 114.20283)
    
    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: photoData.photos
            ) { p in
                MapAnnotation(coordinate: p.coordinate) {
                    AsyncImage(url: p.photo_url) { img in
                        img
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    .shadow(radius: 4)
                }
            }
                .ignoresSafeArea(edges: .top)
                .onAppear{
                    panTo(.dest)
                }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
//                        iconButton("photo.fill",action: {
//                            panTo(.dest, animated: true)
//                        })
                        currentLocationButton()
                            .alert("GPS is turned off", isPresented: $showLocationOffAlert){
                                Button("Got it!", role: .cancel) { }
                            }
                            .alert(isPresented: $showLocationDeinedAlert){
                                Alert(
                                    title: Text("Grant access to your location"),
                                    primaryButton: .default(Text("Change settings")) {
                                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 10)
                }
            }
        }
    }

    private enum PanTarget {
        case dest, user
    }

    private func panTo(_ tar: PanTarget, animated: Bool = false) {
        let coord = (tar == .dest) ? photoData.photos[0].coordinate : lm.locationManager.location!.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        print(coord.latitude.description)
        if animated {
            withAnimation {
                region.center = coord
                region.span = span
            }
        } else {
            region = MKCoordinateRegion(center: coord, span: span)
        }
    }
    
    func iconButton(_ icon: String = "location.fill", color: Color = .accentColor, action: @escaping () -> Void = {  }) -> some View {
        return Button {
            action()
        } label: {
            Image(systemName: icon)
                .padding()
                .foregroundColor(color)
                .background(in: Circle())
        }
    }
    
    private func currentLocationButton() -> some View {
        switch lm.locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            return iconButton(action: {
                panTo(.user, animated: true)
            })
        case .denied, .restricted:
            return iconButton("location.slash", color: .red, action: {
                guard CLLocationManager.locationServicesEnabled() else {
                    showLocationOffAlert = true
                    return
                }
                showLocationDeinedAlert = true
            })
        case .notDetermined:
            return iconButton("location.slash", color: .orange, action: {
                lm.locationManager.requestWhenInUseAuthorization()
            })
        default:
            return iconButton("exclamationmark.circle", color: .gray)
        }
    }
}
