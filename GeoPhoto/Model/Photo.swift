//
//  PhotoModel.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 12/1/2023.
//

import Foundation
import CoreLocation

struct Photo: Identifiable, Codable {
    let id, uuid: String
    let user_id: Int
    var description: String
    var timestamp: Date
    var photo_url: URL?
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
    
    init(uuid: String, user_id: Int, description: String, timestamp: String, photo_url: String, latitude: Double, longitude: Double) {
        self.uuid = uuid
        self.id = uuid
        self.user_id = user_id
        self.description = description
        let isoFormatter = ISO8601DateFormatter()
        self.timestamp = isoFormatter.date(from: timestamp) ?? Date(timeIntervalSinceReferenceDate: 0)
        self.photo_url = URL(string: photo_url)
        self.latitude = latitude
        self.longitude = longitude
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid, user_id, filename, photo_url, description, latitude, longitude, timestamp
    }
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try values.decode(String.self, forKey: .uuid)
        self.id = self.uuid
        self.user_id = try values.decode(Int.self, forKey: .user_id)
        self.description = try values.decode(String.self, forKey: .description)
        let isoFormatter = ISO8601DateFormatter()
        let isoTimestamp = try values.decode(String.self, forKey: .timestamp)
        self.timestamp = isoFormatter.date(from: isoTimestamp) ?? Date(timeIntervalSinceReferenceDate: 0)
        let photo_url = try values.decode(String.self, forKey: .photo_url)
        self.photo_url = URL(string: "\(Configs.serverHost)\(photo_url)")
        self.latitude = try values.decode(Double.self, forKey: .latitude)
        self.longitude = try values.decode(Double.self, forKey: .longitude)
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(description, forKey: .description)
        let isoFormatter = ISO8601DateFormatter()
        let isoTimestamp = isoFormatter.string(from: timestamp)
        try container.encode(isoTimestamp, forKey: .timestamp)
        try container.encode(photo_url?.absoluteString, forKey: .photo_url)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

struct PhotoResponse: Codable {
    let success: Bool
    let photos: [Photo]

    enum CodingKeys: String, CodingKey {
        case success
        case photos = "data"
    }
}
