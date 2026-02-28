//
//  Interceptor.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation
import Core

final class Interceptor: @unchecked Sendable {

    private let localDataSource: AuthLocalDataSource
    private let remoteDataSource: AuthRemoteDataSource
    private let apiKey: String

    init(
        localDataSource: AuthLocalDataSource,
        remoteDataSource: AuthRemoteDataSource,
        apiKey: String
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self.apiKey = apiKey
    }

    /// 요청에 Authorization, apikey, Content-Type 헤더 주입
    func adapt(_ request: URLRequest) -> URLRequest {
        var request = request

        if let token = localDataSource.loadToken() {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }

    /// Keychain의 refreshToken으로 세션 갱신 후 새 토큰 저장
    func refreshToken() async throws {
        guard let token = localDataSource.loadToken() else {
            throw AppError.auth(.sessionExpired)
        }

        let response = try await remoteDataSource.refreshToken(token.refreshToken)
        try localDataSource.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
    }
}
