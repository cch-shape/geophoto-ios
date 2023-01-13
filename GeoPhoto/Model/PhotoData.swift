//
//  PhotoData.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 12/1/2023.
//

import Foundation
import UIKit
import CoreLocation

final class PhotoData: ObservableObject {
    @Published var photos: [PhotoModel] = []
    @Published var isLoading = false
    
    init() {
        fetch()
    }
    
    func fetch() {
        let url = URL(string: "\(Configs.apiBaseURL)/photo")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(UserModel.User.jwt)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { responseData, response, error in
            guard let responseData, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let decoder = JSONDecoder()
                let resModel = try decoder.decode(PhotosResponse.self, from: responseData)
                DispatchQueue.main.async{
                    self.photos = resModel.photos
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func delete(uuid: String) {
        let url = URL(string: "\(Configs.apiBaseURL)/photo/\(uuid)")!
        
        var request = URLRequest(url: url)
        request.setValue( "Bearer \(UserModel.User.jwt)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { _, _, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            guard let index = self.photos.firstIndex(where: {$0.uuid == uuid}) else { return }
            DispatchQueue.main.async {
                self.photos.remove(at: index)
            }
        }
        task.resume()
    }
    
    func post(description: String, image: UIImage, lsmo: LocationSelectionModel.Option) {
        isLoading = true
        let url = URL(string: "\(Configs.apiBaseURL)/photo")
        let boundary = UUID().uuidString
        let session = URLSession.shared
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue( "Bearer \(UserModel.User.jwt)", forHTTPHeaderField: "Authorization")
        
        var data = Data()
        func appendData(_ key: String, _ value: String) {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)\r\n".data(using: .ascii)!)
        }
        func appendFile(_ img: UIImage) {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\("file")\"; filename=\"\("i.jpeg")\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/\("jpeg")\r\n\r\n".data(using: .utf8)!)
            data.append(img.jpegData(compressionQuality: 1.0)!)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        }
        
        appendData("description", description)
        appendData("address_name", lsmo.name)
        appendData("address", lsmo.address)
        appendData("latitude", String(format: "%f", lsmo.coordinate.latitude))
        appendData("longitude", String(format: "%f", lsmo.coordinate.longitude))
        appendData("timestamp", ISO8601DateFormatter().string(from: Date()))
        
        appendFile(image)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            do {
                if error == nil {
                    guard let responseData else { return }
                    let decoder = JSONDecoder()
                    let resModel = try decoder.decode(PhotoResponse.self, from: responseData)
                    DispatchQueue.main.async {
                        self.photos.insert(resModel.photo, at: 0)
                    }
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } catch {
                print(error)
            }
        }).resume()
    }
}
