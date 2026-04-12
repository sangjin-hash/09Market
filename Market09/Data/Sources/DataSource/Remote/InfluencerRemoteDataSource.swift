//
//  InfluencerRemoteDataSource.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import AppCore

protocol InfluencerRemoteDataSource {
    /// POST — 인플루언서 등록
    /// - Parameters:
    ///   - username: 인플루언서 ID
    /// - Throws: `AppError.network(.conflict)` 이미 등록된 경우
    func registerInfluencer(_ username: String) async throws

    /// GET — username 포함 검색 (최대 3개)
    /// - Parameters:
    ///   - username: 검색할 username
    /// - Returns: 매칭된 인플루언서 목록
    func searchInfluencers(_ username: String) async throws -> [InfluencerResponse]
}

final class InfluencerRemoteDataSourceImpl: InfluencerRemoteDataSource {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func registerInfluencer(_ username: String) async throws {
        try await performRequest {
            let endpoint = self.influencerEndpoint()
            let queryItems = [URLQueryItem(name: InfluencerQueryKey.kAction, value: InfluencerAction.kRegister)]
            let body = try JSONEncoder().encode(InfluencerRegisterRequest(instagramUsername: username))
            _ = try await self.apiClient.post(endpoint, queryItems: queryItems, body: body)
        }
    }

    func searchInfluencers(_ username: String) async throws -> [InfluencerResponse] {
        return try await performRequest {
            let endpoint = self.influencerEndpoint()
            let queryItems = [
                URLQueryItem(name: InfluencerQueryKey.kAction, value: InfluencerAction.kSearch),
                URLQueryItem(name: InfluencerQueryKey.kUsername, value: username)
            ]
            let data = try await self.apiClient.get(endpoint, queryItems: queryItems)
            return try JSONDecoder().decode([InfluencerResponse].self, from: data)
        }
    }
}

extension InfluencerRemoteDataSourceImpl {
    func influencerEndpoint() -> String {
        guard let endpoint = Bundle.main.infoDictionary?["API_INFLUENCER"] as? String else {
            fatalError("API_INFLUENCER가 Info.plist에 없습니다. Secrets.xcconfig을 확인하세요.")
        }
        return endpoint
    }

    @discardableResult
    func performRequest<T>(_ operation: () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch AppError.network(.serverError(let statusCode)) where statusCode == 409 {
            throw AppError.network(.conflict)
        } catch let error as AppError {
            throw error
        } catch is DecodingError {
            throw AppError.network(.invalidResponse)
        } catch {
            throw AppError.unknown(message: error.localizedDescription)
        }
    }
}

private enum InfluencerQueryKey {
    static let kAction = "action"
    static let kUsername = "username"
}

private enum InfluencerAction {
    static let kRegister = "register"
    static let kSearch = "search"
}
