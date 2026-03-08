//
//  UserRemoteDataSource.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import Core

protocol UserRemoteDataSource {
    /// GET /me — 유저  조회
    /// - Returns: 소셜 유저면 User, 익명 로그인이면 nil
    func getMe() async throws -> UserResponse?
}

final class UserRemoteDataSourceImpl: UserRemoteDataSource {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getMe() async throws -> UserResponse? {
        return try await performRequest {
            guard let endpoint = Bundle.main.infoDictionary?["API_ME"] as? String else {
                fatalError("API_ME가 Info.plist에 없습니다. Secrets.xcconfig을 확인하세요.")
            }
            let data = try await self.apiClient.get(endpoint)

            if data.isEmpty { return nil }
            return try JSONDecoder().decode(UserResponse.self, from: data)
        }
    }
}

extension UserRemoteDataSourceImpl {
    
    // MARK: - Private

    @discardableResult
    private func performRequest<T>(_ operation: () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch let error as AppError {
            throw error
        } catch is DecodingError {
            throw AppError.network(.invalidResponse)
        } catch {
            throw AppError.unknown(message: error.localizedDescription)
        }
    }
}
