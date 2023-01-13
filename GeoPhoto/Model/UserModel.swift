//
//  UserModel.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 13/1/2023.
//

import Foundation
import AuthenticationServices

final class UserModel: ObservableObject {
    struct User: Decodable {
        var id: Int
        var phone_number: String
        var name: String?
        var thumbnail_url: String?
        static var jwt: String = ""
        static var currentUser: User? = nil
        
        enum CodingKeys: String, CodingKey {
            case id, phone_number, name, thumbnail_url
        }
        
        init(from decoder:Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try values.decode(Int.self, forKey: .id)
            self.phone_number = try values.decode(String.self, forKey: .phone_number)
            self.name = try values.decode(String.self, forKey: .name)
            self.thumbnail_url = try values.decode(String.self, forKey: .thumbnail_url)
        }
    }
    
    struct UserResponse: Decodable {
        let success: Bool
        let user: User
        
        enum CodingKeys: String, CodingKey {
            case success
            case user = "data"
        }
    }
    /*
     unchecked is the initial state, the init func with try to loggin with the jwt stored in keychain
     change to loggedIn if success, else loggedOut
     */
    enum AuthorizationStatus { case uncheck, loggedIn, loggedOut }
    @Published var authorizationStatus: AuthorizationStatus = .uncheck
    
    // Demo use, since we don't have sms service. Used to store and display verification code directlry
    @Published var verificationCode: String = ""
    
    init() {
        loadJwt()
        getMe()
    }
    
    func askVerificationCode(phoneNumber: String) {
        let json: [String: String] = ["phone_number": phoneNumber]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "\(Configs.apiBaseURL)/ask/verification")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { responseData, response, error in
            guard let responseData, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: responseData, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if let data = responseJSON["data"] as? [String: Any] {
                    DispatchQueue.main.async {
                        self.verificationCode = data["verification_code"] as? String ?? ""
                    }
                }
            }
        }
        task.resume()
    }
    
    func login(phoneNumber: String, verificationCode: String) {
        let json: [String: String] = ["phone_number": phoneNumber, "verification_code": verificationCode]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "\(Configs.apiBaseURL)/login")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { responseData, response, error in
            guard let responseData, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: responseData, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                let jwt = responseJSON["data"] as? String ?? "1"
                self.saveJwt(jwt: jwt)
                self.getMe()
                DispatchQueue.main.async {
                    self.verificationCode = ""
                }
            }
        }
        task.resume()
    }
    
    func getMe() {
        let url = URL(string: "\(Configs.apiBaseURL)/user/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(User.jwt)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { responseData, response, error in
            guard let responseData, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let decoder = JSONDecoder()
                let resModel = try decoder.decode(UserResponse.self, from: responseData)
                DispatchQueue.main.async {
                    UserModel.User.currentUser = resModel.user
                    self.authorizationStatus = .loggedIn
                }
            } catch {
                DispatchQueue.main.async {
                    self.authorizationStatus = .loggedOut
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func logout() {
        User.jwt = ""
        Keystore.delete(service: "jwt", account: "geophoto")
        authorizationStatus = .loggedOut
    }
    
    func loadJwt() {
        let data = Keystore.read(service: "jwt", account: "geophoto") ?? Data()
        User.jwt = String(decoding: data, as: UTF8.self)
    }
    
    func saveJwt(jwt: String) {
        User.jwt = jwt
        let data = jwt.data(using: String.Encoding.utf8) ?? Data()
        Keystore.save(data, service: "jwt", account: "geophoto")
    }
}
