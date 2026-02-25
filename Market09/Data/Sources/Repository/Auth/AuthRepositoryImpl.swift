//
//  AuthRepositoryImpl.swift
//  Data
//
//  Created by Sangjin Lee
//

import Core
import Domain

public final class AuthRepositoryImpl: AuthRepository {
    
    private let remoteDataSource: AuthRemoteDataSource
    private let keychainClient: KeychainClient
    
    private init(
        remoteDataSource: AuthRemoteDataSource,
        keychainClient: KeychainClient
    ) {
        self.remoteDataSource = remoteDataSource
        self.keychainClient = keychainClient
    }
    
    public func signInAnonymously() async throws -> AuthToken {
        let response = try await remoteDataSource.signInAnonymously()
        try saveTokens(response)
        return AuthMapper.toAuthTokenEntity(response)
    }
    
    public func signInWithIdToken(
        provider: String,
        idToken: String,
        nonce: String?
    ) async throws -> AuthToken {
        let response = try await remoteDataSource.signInWithIdToken(
            provider: provider,
            idToken: idToken,
            nonce: nonce
        )
        try saveTokens(response)
        return AuthMapper.toAuthTokenEntity(response)
    }
    
    public func refreshToken(_ refreshToken: String) async throws -> AuthToken {
        let response = try await remoteDataSource.refreshToken(refreshToken)
        try saveTokens(response)
        return AuthMapper.toAuthTokenEntity(response)
    }
    
    public func signOut() async throws {
        try await remoteDataSource.signOut()
        try clearTokens()
    }
    
    public func deleteAccount() async throws {
        try await remoteDataSource.deleteAccount()
        try clearTokens()
    }
    
    // MARK: - Private
    
    private func saveTokens(_ response: AuthTokenResponse) throws {
        guard let accessToken = response.accessToken.data(using: .utf8),
              let refreshToken = response.refreshToken.data(using: .utf8) else {
            throw AppError.storage(.saveFailed)
        }
        
        do {
            try keychainClient.save(key: Constants.KeychainKey.accessToken, data: accessToken)
            try keychainClient.save(key: Constants.KeychainKey.refreshToken, data: refreshToken)
        } catch let error as KeychainError {
            throw KeychainErrorMapper.map(error)
        }
    }

    private func clearTokens() throws {
        do {
            try keychainClient.deleteAll()
        } catch let error as KeychainError {
            throw KeychainErrorMapper.map(error)
        }
    }
}
