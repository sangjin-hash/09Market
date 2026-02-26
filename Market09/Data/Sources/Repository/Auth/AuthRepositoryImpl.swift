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
    private let localDataSource: AuthLocalDataSource

    public init(
        remoteDataSource: AuthRemoteDataSource,
        localDataSource: AuthLocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    // MARK: - SignIn

    public func signInAnonymously() async throws -> AuthToken {
        let response = try await remoteDataSource.signInAnonymously()
        try localDataSource.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        try localDataSource.saveAnonymousFlag(true)
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
        
        try localDataSource.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        try localDataSource.saveAnonymousFlag(false)
        return AuthMapper.toAuthTokenEntity(response)
    }

    // MARK: - Token

    public func refreshToken() async throws -> AuthToken {
        guard let token = localDataSource.loadToken() else {
            throw AppError.storage(.notFound)
        }
        
        let response = try await remoteDataSource.refreshToken(token.refreshToken)
        try localDataSource.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        return AuthMapper.toAuthTokenEntity(response)
    }

    public func currentTokenStatus() -> TokenStatus {
        TokenStatus.evaluate(
            token: localDataSource.loadToken(),
            isAnonymous: localDataSource.isAnonymous()
        )
    }

    public func clearToken() throws {
        try localDataSource.clearTokens()
    }

    // MARK: - SignOut & Delete Account

    public func signOut() async throws {
        try await remoteDataSource.signOut()
        try localDataSource.clearTokens()
    }

    public func deleteAccount() async throws {
        try await remoteDataSource.deleteAccount()
        try localDataSource.clearTokens()
    }
}
