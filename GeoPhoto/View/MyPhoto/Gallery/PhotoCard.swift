//
//  PhotoCard.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 11/1/2023.
//

import SwiftUI

struct PhotoCard: View {
    let size: Double
    let url: URL?
    
    var body: some View {
        AsyncImage(url: url) { img in
            img
                .resizable()
                .scaledToFill()
        } placeholder: {
            ProgressView()
        }
        .frame(width: size, height: size)
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}
