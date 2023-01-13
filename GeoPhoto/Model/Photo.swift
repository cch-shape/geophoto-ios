//
//  PhotoModel.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 12/1/2023.
//

import Foundation
import CoreLocation

struct Photo: Identifiable, Decodable {
    let id, uuid: String
    let user_id: Int
    var description: String?
    var address_name: String?
    var address: String?
    var timestamp: Date
    var photo_url: URL?
    var thumbnail_url_1x: URL?
    var thumbnail_url_2x: URL?
    var coordinate: CLLocationCoordinate2D
    var latitude: CLLocationDegrees {
        didSet {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    var longitude: CLLocationDegrees {
        didSet {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    var file: Data? = nil
    
    enum CodingKeys: String, CodingKey {
        case uuid, user_id, filename, photo_url, thumbnail_url_1x, thumbnail_url_2x, description, address_name, address, latitude, longitude, timestamp, file
    }
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try values.decode(String.self, forKey: .uuid)
        self.id = self.uuid
        self.user_id = try values.decode(Int.self, forKey: .user_id)
        self.description = try values.decode(String.self, forKey: .description)
        self.address_name = try values.decode(String.self, forKey: .address_name)
        self.address = try values.decode(String.self, forKey: .address)
        let isoFormatter = ISO8601DateFormatter()
        let isoTimestamp = try values.decode(String.self, forKey: .timestamp)
        self.timestamp = isoFormatter.date(from: isoTimestamp) ?? Date(timeIntervalSinceReferenceDate: 0)
        let photo_url = try values.decode(String.self, forKey: .photo_url)
        self.photo_url = URL(string: "\(Configs.serverHost)\(photo_url)")
        let thumbnail_url_1x = try values.decode(String.self, forKey: .thumbnail_url_1x)
        self.thumbnail_url_1x = URL(string: "\(Configs.serverHost)\(thumbnail_url_1x)")
        let thumbnail_url_2x = try values.decode(String.self, forKey: .thumbnail_url_2x)
        self.thumbnail_url_2x = URL(string: "\(Configs.serverHost)\(thumbnail_url_2x)")
        self.latitude = try values.decode(Double.self, forKey: .latitude)
        self.longitude = try values.decode(Double.self, forKey: .longitude)
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct PhotosResponse: Decodable{
    let success: Bool
    let photos: [Photo]

    enum CodingKeys: String, CodingKey {
        case success
        case photos = "data"
    }
}

struct PhotoResponse: Decodable {
    let success: Bool
    let photo: Photo

    enum CodingKeys: String, CodingKey {
        case success
        case photo = "data"
    }
}
