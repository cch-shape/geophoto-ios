//
//  MyPhoto.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI

struct MyPhoto: View {
    @State private var isCreating = false
    @StateObject var locationModel = LocationModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Gallery()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isCreating = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationBarTitle("My Photo")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isCreating) {
                NewPhotoForm()
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
