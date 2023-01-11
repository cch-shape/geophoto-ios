//
//  PhotoList.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI

struct Gallery: View {
    @EnvironmentObject var photoData: PhotoData
    private var cols = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: cols) {
                ForEach(photoData.photos) { p in
                    GeometryReader { reader in
//                        NavigationLink(destination: Settings()) {
//                            PhotoCard(size: reader.size.width)
//                        }
                        PhotoCard(size: reader.size.width, url: p.photo_url)
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding()
        }
    }
}

struct Gallery_Previews: PreviewProvider {
    static var previews: some View {
        Gallery()
    }
}
