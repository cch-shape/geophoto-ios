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
    @StateObject var lm = LocationModel()
    @Binding var region: MKCoordinateRegion
    struct Marker: Identifiable {
        let id = UUID()
    }

    @State private var showLocationOffAlert = false
    @State private var showLocationDeinedAlert = false
    
    @State private var searchMode = false
    private var searchModeBindWrapper: Binding<Bool> { Binding (
        get: { self.searchMode },
        set: { v in
            if v {
                self.searchMode = v
                return
            }
            switch lm.locationManager.authorizationStatus {
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
                lm.locationManager.requestWhenInUseAuthorization()
                return
            default:
                return
            }
        }
    )}
    @State private var query = ""
    @State private var reselectingAddress = false
    @State private var showNoResultAlert = false
    @FocusState private var searchFocusing: Bool
    @StateObject private var queryResult = LocationQueryResult()
    
    var body: some View {
        VStack(spacing: 8) {
            ModeSwitcher
            
            MiniMap
            
            if searchMode {
                if reselectingAddress || queryResult.selected.address.isEmpty {
                    AddressSearchGroup
                } else {
                    Button {
                        query = queryResult.selected.name
                        reselectingAddress = true
                        searchFocusing = true
                    } label: {
                        AddressFooter
                    }
                }
            } else if !queryResult.selected.address.isEmpty {
                AddressFooter
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
            coord = queryResult.selected.coordinate
        } else {
            guard let c = lm.locationManager.location?.coordinate else { return }
            coord = c
            queryResult.selected.coordinate = coord
            geocodingCurrentLocation()
        }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        region = MKCoordinateRegion(center: coord, span: span)
    }
    
    private func searchLocation(query: String) {
        queryResult.dismiss()
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                showNoResultAlert = true
                return
            }
            DispatchQueue.main.async() {
                for item in response.mapItems {
                    if let name = item.name, let location = item.placemark.location {
                        queryResult.append(name: name, address: item.placemark.title ?? "", coordinate: location.coordinate)
                    }
                }
                if queryResult.options.isEmpty {
                    showNoResultAlert = true
                } else {
                    queryResult.show()
                }
            }
        }
    }
    
    private func geocodingCurrentLocation() {
        guard !searchMode && lm.locationManager.authorizationStatus == .authorizedWhenInUse else { return }
        guard let coord = lm.locationManager.location?.coordinate else { return }
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coord.latitude, longitude: coord.longitude)) { placemarks, error in
            guard let placemark = placemarks?.first else { return }
            let formatter = CNPostalAddressFormatter()
            let address = formatter.string(from: placemark.postalAddress!).split(separator: "\n").reversed().joined(separator: ", ")
            queryResult.selected.address = address
        }
    }
    
    // Custom Views
    var ModeSwitcher: some View {
        Picker("EditMode`", selection: searchModeBindWrapper) {
            Image(systemName: lm.locationManager.authorizationStatus == .authorizedWhenInUse ? "pin.fill" : "pin.slash")
                .tag(false)
            Image(systemName: "magnifyingglass")
                .tag(true)
        }
        .pickerStyle(.segmented)
        .alert("GPS is turned off", isPresented: $showLocationOffAlert){
            Button("Got it!", role: .cancel) { }
        }
        .alert("Grant access to your location", isPresented: $showLocationDeinedAlert) {
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
                annotationItems: searchMode ? [queryResult.selected] : []
            ) { item in
                MapMarker(coordinate: item.coordinate)
            }
            .onAppear{
                searchMode = lm.locationManager.authorizationStatus != .authorizedWhenInUse
                panTo()
            }
            .onChange(of: searchMode, perform: { _ in
                panTo()
            })
            .onChange(of: lm.locationManager.authorizationStatus, perform: { status in
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
                        Button {
                            panTo()
                        } label: {
                            Image(systemName: "location.fill")
                                .padding()
                                .background(in: Circle())
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                }
                Spacer()
            }
        }
    }
    
    var AddressSearchGroup: some View {
        HStack {
            Image(systemName: "location.magnifyingglass")
                .foregroundColor(Color(UIColor.placeholderText))
            TextField("Search Location...", text: $query)
                .focused($searchFocusing)
                .submitLabel(.return)
                .alert("No match found", isPresented: $showNoResultAlert) {
                    Button("Try Again") {
                        searchFocusing = true
                    }
                    Button("Cancel", role: .cancel) {
                        reselectingAddress = false
                    }
                }
            if !query.isEmpty {
                if searchFocusing {
                    Button {
                        searchLocation(query: query)
                    } label: {
                        Text("Search")
                    }
                } else {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemGroupedBackground)))
        .sheet(isPresented: $queryResult.showQueryResult) { QueryResultSheet }
    }
    
    var AddressFooter: some View {
        Text(queryResult.selected.address)
            .font(.footnote)
    }
    
    var QueryResultSheet: some View {
        NavigationView {
            List(queryResult.options) { result in
                Button {
                    queryResult.select(result)
                    query = ""
                    reselectingAddress = false
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
                        queryResult.dismiss()
                    }
                }
            }
            .navigationTitle("Select location")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
