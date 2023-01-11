//
//  PhotoData.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 12/1/2023.
//

import Foundation

final class PhotoData: ObservableObject {
    @Published var photos: [Photo] = []
    
    init() {
        let url = URL(string: "\(Configs.apiBaseURL)/photo")!
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                let res = try decoder.decode(PhotoResponse.self, from: data)
                DispatchQueue.main.async{
                    self.photos = res.photos
                }
            } catch {
                print(error)
            }
        }
    }
}
