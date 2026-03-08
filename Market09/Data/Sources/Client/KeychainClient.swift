//
//  KeychainClient.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import Core

enum Constants {
    static let bundleId = "com.ios.market09"

    enum KeychainKey {
        static let accessToken = "market09.accessToken"
        static let refreshToken = "market09.refreshToken"
        static let isAnonymous = "market09.isAnonymous"
    }
}

public protocol KeychainClient {
    func save(key: String, data: Data) throws
    func load(key: String) -> Data?
    func delete(key: String) throws
    func deleteAll() throws
}

public final class KeychainClientImpl: KeychainClient {
    private let service: String = Constants.bundleId

    public init() {}
    
    public func save(key: String, data: Data) throws {
        try? delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    public func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
    
    public func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
    
    public func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

public enum KeychainError: Error {
    case saveFailed(OSStatus)
    case deleteFailed(OSStatus)
}
