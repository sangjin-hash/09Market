//
//  UserRemoteDataSource.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import AppCore

protocol UserRemoteDataSource {
    /// GET /me — 유저  조회
    /// - Returns: 소셜 유저면 User, 익명 로그인이면 nil
    func fetchMe() async throws -> UserResponse?
}

final class UserRemoteDataSourceImpl: UserRemoteDataSource, RemoteDataSource {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchMe() async throws -> UserResponse? {
        return try await performRequest {
            let endpoint = self.postsEndpoint()
            let data = try await self.apiClient.get(endpoint)

            if data.isEmpty { return nil }
            return try JSONDecoder().decode(UserResponse.self, from: data)
        }
    }
}

extension UserRemoteDataSourceImpl {
    private func postsEndpoint() -> String {
        guard let endpoint = Bundle.main.infoDictionary?["API_ME"] as? String else {
            fatalError("API_ME가 Info.plist에 없습니다. Secrets.xcconfig을 확인하세요.")
        }
        return endpoint
    }
}
