//
//  Keystore.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 13/1/2023.
//  Source: https://www.swiftdevjournal.com/saving-passwords-in-the-keychain-in-swift/

import Foundation

final class Keystore {
    static func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
            
        let saveStatus = SecItemAdd(query, nil)
     
        if saveStatus != errSecSuccess {
            print("Error: \(saveStatus)")
        }
        
        if saveStatus == errSecDuplicateItem {
            update(data, service: service, account: account)
        }
    }
    
    static func update(_ data: Data, service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
            
        let updatedData = [kSecValueData: data] as CFDictionary
        SecItemUpdate(query, updatedData)
    }
    
    static func read(service: String, account: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
        ] as CFDictionary
            
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        return result as? Data
    }
    
    static func delete(service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
            
        SecItemDelete(query)
    }
}
