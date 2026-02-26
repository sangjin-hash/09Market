//
//  AuthLocalDataSource.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation
import Core
import Domain

public protocol AuthLocalDataSource {
    /// Keychain에 access/refresh 토큰을 저장
    /// - Parameters:
    ///   - accessToken: Supabase Access Token (JWT)
    ///   - refreshToken: Supabase Refresh Token
    func saveTokens(accessToken: String, refreshToken: String) throws

    /// Keychain에서 저장된 토큰을 로드
    /// - Returns: 저장된 토큰이 있으면 AuthToken, 없으면 nil
    func loadToken() -> AuthToken?

    /// Keychain에 저장된 모든 인증 데이터를 삭제
    func clearTokens() throws

    /// 익명 로그인 여부를 Keychain에 저장
    /// - Parameter isAnonymous: 익명 로그인이면 true, 소셜 로그인이면 false
    func saveAnonymousFlag(_ isAnonymous: Bool) throws

    /// Keychain에서 익명 로그인 여부를 조회
    /// - Returns: 익명 로그인이면 true (기본값: true)
    func isAnonymous() -> Bool
}

public final class AuthLocalDataSourceImpl: AuthLocalDataSource {

    private let keychainClient: KeychainClient

    public init(keychainClient: KeychainClient) {
        self.keychainClient = keychainClient
    }

    public func saveTokens(accessToken: String, refreshToken: String) throws {
        guard let accessData = accessToken.data(using: .utf8),
              let refreshData = refreshToken.data(using: .utf8) else {
            throw AppError.storage(.saveFailed)
        }

        do {
            try keychainClient.save(key: Constants.KeychainKey.accessToken, data: accessData)
            try keychainClient.save(key: Constants.KeychainKey.refreshToken, data: refreshData)
        } catch let error as KeychainError {
            throw KeychainErrorMapper.map(error)
        }
    }

    public func loadToken() -> AuthToken? {
        guard let accessData = keychainClient.load(key: Constants.KeychainKey.accessToken),
              let refreshData = keychainClient.load(key: Constants.KeychainKey.refreshToken),
              let accessToken = String(data: accessData, encoding: .utf8),
              let refreshToken = String(data: refreshData, encoding: .utf8) else {
            return nil
        }
        
        return AuthToken(accessToken: accessToken, refreshToken: refreshToken)
    }

    public func clearTokens() throws {
        do {
            try keychainClient.deleteAll()
        } catch let error as KeychainError {
            throw KeychainErrorMapper.map(error)
        }
    }

    public func saveAnonymousFlag(_ isAnonymous: Bool) throws {
        guard let data = String(isAnonymous).data(using: .utf8) else {
            throw AppError.storage(.saveFailed)
        }
        
        do {
            try keychainClient.save(key: Constants.KeychainKey.isAnonymous, data: data)
        } catch let error as KeychainError {
            throw KeychainErrorMapper.map(error)
        }
    }

    public func isAnonymous() -> Bool {
        guard let data = keychainClient.load(key: Constants.KeychainKey.isAnonymous),
              let value = String(data: data, encoding: .utf8) else {
            return true
        }
        
        return value == "true"
    }
}
