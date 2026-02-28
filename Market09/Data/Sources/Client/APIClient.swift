//
//  APIClient.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation
import Core

// MARK: - APIClient Protocol

public protocol APIClient {
    func get(_ endpoint: String) async throws -> Data
    func post(_ endpoint: String, body: Data?) async throws -> Data
    func put(_ endpoint: String, body: Data?) async throws -> Data
    func delete(_ endpoint: String) async throws -> Void
    func patch(_ endpoint: String, body: Data?) async throws -> Data
}

// MARK: - APIClientImpl

final class APIClientImpl: APIClient, @unchecked Sendable {

    private let baseURL: String
    private let session: URLSession
    private let interceptor: Interceptor

    init(baseURL: String, interceptor: Interceptor) {
        self.baseURL = baseURL

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)

        self.interceptor = interceptor
    }

    // MARK: - Public Methods

    func get(_ endpoint: String) async throws -> Data {
        try await request(endpoint: endpoint, method: "GET")
    }

    func post(_ endpoint: String, body: Data?) async throws -> Data {
        try await request(endpoint: endpoint, method: "POST", body: body)
    }

    func put(_ endpoint: String, body: Data?) async throws -> Data {
        try await request(endpoint: endpoint, method: "PUT", body: body)
    }

    func delete(_ endpoint: String) async throws {
        _ = try await request(endpoint: endpoint, method: "DELETE")
    }

    func patch(_ endpoint: String, body: Data?) async throws -> Data {
        try await request(endpoint: endpoint, method: "PATCH", body: body)
    }

    // MARK: - Private

    private func request(
        endpoint: String,
        method: String,
        body: Data? = nil
    ) async throws -> Data {
        let urlString = baseURL + endpoint
        guard let url = URL(string: urlString) else {
            throw AppError.network(.invalidResponse)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = body
        urlRequest = interceptor.adapt(urlRequest)

        let (data, response) = try await execute(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.network(.invalidResponse)
        }

        switch httpResponse.statusCode {
        case 200...299:
            return data

        case 401:
            return try await retryAfterRefresh(urlRequest)

        case 404:
            throw AppError.network(.notFound)

        case 500...599:
            throw AppError.network(.serverError(statusCode: httpResponse.statusCode))

        default:
            throw AppError.network(.serverError(statusCode: httpResponse.statusCode))
        }
    }

    /// 401 응답 시 토큰 리프레시 후 1회 재시도
    private func retryAfterRefresh(_ originalRequest: URLRequest) async throws -> Data {
        try await interceptor.refreshToken()

        var retryRequest = originalRequest
        retryRequest = interceptor.adapt(retryRequest)

        let (data, response) = try await execute(retryRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AppError.auth(.sessionExpired)
        }

        return data
    }

    private func execute(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch let error as URLError {
            throw NetworkErrorMapper.map(error)
        }
    }
}
