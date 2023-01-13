//
//  LocationPicker.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 12/1/2023.
//

import SwiftUI
import MapKit
import Contacts

struct LocationPicker: View {
    @State var region: MKCoordinateRegion
    @State var searchMode: Bool
    
    @ObservedObject var locationSelection: LocationSelectionModel
    @EnvironmentObject var locationModel: LocationModel
    @EnvironmentObject var photoData: PhotoData
    struct Marker: Identifiable {
        let id = UUID()
    }

    @State private var showLocationOffAlert = false
    @State private var showLocationDeinedAlert = false

    private var searchModeBindWrapper: Binding<Bool> { Binding (
        get: { self.searchMode },
        set: { v in
            if v {
                self.searchMode = v
                return
            }
            switch locationModel.locationManager.authorizationStatus {
            case .authorizedWhenInUse:
                self.searchMode = v
                return
            case .denied, .restricted:
                guard CLLocationManager.locationServicesEnabled() else {
                    showLocationOffAlert = true
                    return
                }
                showLocationDeinedAlert = true
            case .notDetermined:
                locationModel.locationManager.requestWhenInUseAuthorization()
                return
            default:
                return
            }
        }
    )}
    @State private var query = ""
    @State private var showSelectionSheet = false
    @State private var reselectingAddress = false
    @State private var showNoResultAlert = false
    @FocusState private var searchFocusing: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ModeSwitcher
            
            MiniMap
            
            AddressFooter
            
            if searchMode {
                AddressSearchGroup
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }
    
    // Custom functions
    private func panTo() {
        var coord: CLLocationCoordinate2D
        if searchMode {
            coord = locationSelection.selected.coordinate
        } else {
            guard let c = locationModel.locationManager.location?.coordinate else { return }
            coord = c
            locationSelection.selected.coordinate = coord
            geocodingCurrentLocation()
        }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        region = MKCoordinateRegion(center: coord, span: span)
    }
    
    private func searchLocation(query: String) {
        locationSelection.clearOptions()
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                showNoResultAlert = true
                return
            }
            for item in response.mapItems {
                if let name = item.name, let location = item.placemark.location {
                    locationSelection.append(name: name, address: item.placemark.title ?? "", coordinate: location.coordinate)
                }
            }
            if locationSelection.options.isEmpty {
                showNoResultAlert = true
            }
        }
    }
    
    private func geocodingCurrentLocation() {
        guard !searchMode && locationModel.locationManager.authorizationStatus == .authorizedWhenInUse else { return }
        guard let coord = locationModel.locationManager.location?.coordinate else { return }
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coord.latitude, longitude: coord.longitude)) {
            placemarks, error in
            guard let placemark = placemarks?.first else { return }
            DispatchQueue.main.async {
                let formatter = CNPostalAddressFormatter()
                let address = formatter.string(from: placemark.postalAddress!).split(separator: "\n").reversed().joined(separator: ", ")
                locationSelection.select(LocationSelectionModel.Option(
                    name: placemark.name ?? "", address: address, coordinate: coord
                ))
            }
        }
    }
    
    // Custom Views
    var ModeSwitcher: some View {
        Picker("EditMode`", selection: searchModeBindWrapper) {
            Image(systemName: locationModel.locationManager.authorizationStatus == .authorizedWhenInUse ? "pin.fill" : "pin.slash")
                .tag(false)
            Image(systemName: "magnifyingglass")
                .tag(true)
        }
        .pickerStyle(.segmented)
        .alert("GPS is turned off", isPresented: $showLocationOffAlert){
            Button("Got it!", role: .cancel) { }
        }
        .alert(Configs.LocationDeinedMsg, isPresented: $showLocationDeinedAlert) {
            Button("Open Settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    var MiniMap: some View {
        ZStack {
            Map(
                coordinateRegion: $region,
                showsUserLocation: !searchMode,
                annotationItems: searchMode ? [locationSelection.selected] : []
            ) { item in
                MapMarker(coordinate: item.coordinate)
            }
            .onChange(of: searchMode, perform: { _ in
                panTo()
            })
            .onChange(of: locationModel.locationManager.authorizationStatus, perform: { status in
                if status != .authorizedWhenInUse && !searchMode {
                    searchMode = true
                }
            })
            .cornerRadius(10)
            .aspectRatio(1.8, contentMode: .fill)
            
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        Image(systemName: "location.fill")
                            .padding()
                            .background(.background)
                            .onTapGesture {
                                panTo()
                            }
                        .clipShape(Circle())
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .foregroundColor(.accentColor)
                }
                Spacer()
            }
        }.onAppear{
            panTo()
        }
    }
    
    var AddressSearchGroup: some View {
        HStack {
            Image(systemName: "location.magnifyingglass")
                .foregroundColor(Color(UIColor.placeholderText))
            TextField("Search Location...", text: $query)
                .focused($searchFocusing)
                .submitLabel(.search)
                .onSubmit {
                    searchLocation(query: query)
                }
                .alert("No match found", isPresented: $showNoResultAlert) {
                    Button("Try Again") {
                        searchFocusing = true
                    }
                    Button("Cancel", role: .cancel) {
                        query = ""
                    }
                }
            if !query.isEmpty {
                Button {
                    query = ""
                    searchFocusing = false
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemGroupedBackground)))
        .sheet(isPresented: $showSelectionSheet) { QueryResultSheet }
        .onReceive(locationSelection.$options, perform: { opt in
            showSelectionSheet = !opt.isEmpty
        })
    }
    
    var AddressFooter: some View {
        Section {
            Text(locationSelection.selected.name)
                .font(.footnote)
                .bold()
            Text(locationSelection.selected.address)
                .font(.footnote)
        }
    }
    
    var QueryResultSheet: some View {
        NavigationView {
            List(locationSelection.options) { result in
                Button {
                    locationSelection.select(result)
                    query = ""
                    panTo()
                } label: {
                    VStack(alignment: .leading) {
                        Text(result.name)
                            .font(.title3)
                        Text(result.address)
                            .foregroundColor(.gray)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        locationSelection.clearOptions()
                    }
                }
            }
            .navigationTitle("Select location")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LocationPicker_Previews: PreviewProvider {
    static var previews: some View {
        LocationPicker(region: MKCoordinateRegion(), searchMode: false, locationSelection: LocationSelectionModel())
            .environmentObject(PhotoData())
            .environmentObject(LocationModel())
    }
}

