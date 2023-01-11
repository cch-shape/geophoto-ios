//
//  MyPhoto.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI

enum ViewState {
    case gallery
    case timeline
}

struct MyPhoto: View {
    @State var viewState: ViewState = .gallery
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewState {
                case .gallery:
                    Gallery()
                case .timeline:
                    Timeline()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print("add")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Picker("ViewState", selection: $viewState) {
                        Text("Gallery").tag(ViewState.gallery)
                        Text("Timeline").tag(ViewState.timeline)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationBarTitle("My Photo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MyPhoto_Previews: PreviewProvider {
    static var previews: some View {
        MyPhoto()
    }
}
