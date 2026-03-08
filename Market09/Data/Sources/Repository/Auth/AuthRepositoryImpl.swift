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
        let response = try await self.remoteDataSource.signInAnonymously()
        try self.localDataSource.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        try self.localDataSource.saveAnonymousFlag(true)
        return AuthMapper.toAuthTokenEntity(response)
    }

    public func signInWithIdToken(
        provider: AuthProvider,
        idToken: String,
        nonce: String?
    ) async throws -> AuthToken {
        let response = try await self.remoteDataSource.signInWithIdToken(
            provider: provider,
            idToken: idToken,
            nonce: nonce
        )
        
        try self.localDataSource.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        try self.localDataSource.saveAnonymousFlag(false)
        return AuthMapper.toAuthTokenEntity(response)
    }


    // MARK: - Token

    public func refreshToken() async throws -> AuthToken {
        guard let token = self.localDataSource.loadToken() else {
            throw AppError.storage(.notFound)
        }
        
        let response = try await self.remoteDataSource.refreshToken(token.refreshToken)
        try self.localDataSource.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        return AuthMapper.toAuthTokenEntity(response)
    }

    public func currentTokenStatus() -> TokenStatus {
        return TokenStatus.evaluate(
            token: self.localDataSource.loadToken(),
            isAnonymous: self.localDataSource.isAnonymous()
        )
    }

    public func clearToken() throws {
        try self.localDataSource.clearTokens()
    }


    // MARK: - SignOut & Delete Account

    public func signOut(provider: AuthProvider) async throws {
        try await self.remoteDataSource.signOut(provider: provider)
        try self.localDataSource.clearTokens()
    }

    public func deleteAccount() async throws {
        try await self.remoteDataSource.deleteAccount()
        try self.localDataSource.clearTokens()
    }
}
