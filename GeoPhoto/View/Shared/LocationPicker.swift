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
    @StateObject private var queryResult = QueryResult()
    
    var body: some View {
        VStack(spacing: 8) {
            Picker("EditMode`", selection: searchModeBindWrapper) {
                Image(systemName: lm.locationManager.authorizationStatus == .authorizedWhenInUse ? "pin.fill" : "pin.slash")
                    .tag(false)
                Image(systemName: "magnifyingglass")
                    .tag(true)
            }
            .pickerStyle(.segmented)
            
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
                .aspectRatio(1.6, contentMode: .fill)
                
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
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                    }
                    Spacer()
                }
            }
            
            if searchMode {
                if reselectingAddress || queryResult.selected.address.isEmpty {
                    HStack {
                        Image(systemName: "location.magnifyingglass")
                            .foregroundColor(Color(UIColor.placeholderText))
                        TextField("Search Location...", text: $query)
                            .focused($searchFocusing)
                            .onSubmit {
                                searchLocation(query: query)
                            }
                            .submitLabel(.search)
                            .alert(isPresented: $showNoResultAlert){
                                Alert(
                                    title: Text("No matching location found"),
                                    primaryButton: .default(Text("Try again")) {
                                        searchFocusing = true
                                    },
                                    secondaryButton: .cancel() {
                                        reselectingAddress = false
                                    }
                                )
                            }
                        if searchFocusing {
                            Button {
                                query = ""
                                searchFocusing = false
                                reselectingAddress = false
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemGroupedBackground)))
                    .sheet(isPresented: $queryResult.showQueryResult) { QueryResultSheet }
                } else {
                    Button {
                        query = queryResult.selected.name
                        reselectingAddress = true
                        searchFocusing = true
                    } label: {
                        Text(queryResult.selected.address)
                            .font(.footnote)
                    }
                }
            } else if !queryResult.selected.address.isEmpty {
                Text(queryResult.selected.address)
                    .font(.footnote)
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }
    
    
    private func panTo() {
        var coord: CLLocationCoordinate2D
        if searchMode {
            coord = queryResult.selected.coordinate
        } else {
            guard let c = lm.locationManager.location?.coordinate else { return }
            coord = c
        }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        region = MKCoordinateRegion(center: coord, span: span)
        queryResult.selected.coordinate = coord
        geocodingCurrentLocation()
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
    
    class QueryResult: ObservableObject{
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
}
