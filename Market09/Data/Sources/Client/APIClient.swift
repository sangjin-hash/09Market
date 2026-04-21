//
//  APIClient.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import AppCore

// MARK: - APIClient Protocol

public protocol APIClient {
    func get(_ endpoint: String) async throws -> Data
    func get(_ endpoint: String, queryItems: [URLQueryItem]) async throws -> Data
    func post(_ endpoint: String, body: Data?) async throws -> Data
    func post(_ endpoint: String, queryItems: [URLQueryItem], body: Data?) async throws -> Data
    func put(_ endpoint: String, body: Data?) async throws -> Data
    func delete(_ endpoint: String) async throws -> Void
    func delete(_ endpoint: String, queryItems: [URLQueryItem]) async throws -> Void
    func patch(_ endpoint: String, body: Data?) async throws -> Data
    func upload(_ endpoint: String, imageData: Data, mimeType: String) async throws -> Data
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
        return try await request(endpoint: endpoint, method: "GET")
    }

    func get(_ endpoint: String, queryItems: [URLQueryItem]) async throws -> Data {
        return try await request(endpoint: endpoint, method: "GET", queryItems: queryItems)
    }

    func post(_ endpoint: String, body: Data?) async throws -> Data {
        return try await request(endpoint: endpoint, method: "POST", body: body)
    }

    func post(_ endpoint: String, queryItems: [URLQueryItem], body: Data?) async throws -> Data {
        return try await request(endpoint: endpoint, method: "POST", queryItems: queryItems, body: body)
    }

    func put(_ endpoint: String, body: Data?) async throws -> Data {
        return try await request(endpoint: endpoint, method: "PUT", body: body)
    }

    func delete(_ endpoint: String) async throws {
        _ = try await request(endpoint: endpoint, method: "DELETE")
    }

    func delete(_ endpoint: String, queryItems: [URLQueryItem]) async throws {
        _ = try await request(endpoint: endpoint, method: "DELETE", queryItems: queryItems)
    }

    func patch(_ endpoint: String, body: Data?) async throws -> Data {
        return try await request(endpoint: endpoint, method: "PATCH", body: body)
    }

    func upload(_ endpoint: String, imageData: Data, mimeType: String) async throws -> Data {
        let boundary = UUID().uuidString

        guard let url = URL(string: self.baseURL + endpoint) else {
            throw AppError.network(.invalidResponse)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest = self.interceptor.adapt(urlRequest)
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = self.makeMultipartBody(imageData: imageData, mimeType: mimeType, boundary: boundary)

        let (data, response) = try await execute(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.network(.invalidResponse)
        }

        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 400:
            throw AppError.network(.badRequest)
        case 401:
            return try await retryAfterRefresh(urlRequest)
        case 404:
            throw AppError.network(.notFound)
        case 409:
            let errorCode = Self.parseErrorCode(from: data)
            throw AppError.network(.conflict(ServerErrorCode(code: errorCode)))
        case 429:
            throw AppError.network(.rateLimited)
        case 500...599:
            throw AppError.network(.serverError(statusCode: httpResponse.statusCode))
        default:
            throw AppError.network(.invalidResponse)
        }
    }
}


// MARK: - Private

private extension APIClientImpl {
    func request(
        endpoint: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        body: Data? = nil
    ) async throws -> Data {
        let urlString = self.baseURL + endpoint
        guard var components = URLComponents(string: urlString) else {
            throw AppError.network(.invalidResponse)
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw AppError.network(.invalidResponse)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = body
        urlRequest = self.interceptor.adapt(urlRequest)

        let (data, response) = try await execute(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.network(.invalidResponse)
        }

        switch httpResponse.statusCode {
        case 200...299:
            return data

        case 400:
            throw AppError.network(.badRequest)

        case 401:
            return try await retryAfterRefresh(urlRequest)

        case 404:
            throw AppError.network(.notFound)

        case 409:
            let errorCode = Self.parseErrorCode(from: data)
            throw AppError.network(.conflict(ServerErrorCode(code: errorCode)))

        case 429:
            throw AppError.network(.rateLimited)

        case 500...599:
            throw AppError.network(.serverError(statusCode: httpResponse.statusCode))

        default:
            throw AppError.network(.invalidResponse)
        }
    }

    /// 401 응답 시 토큰 리프레시 후 1회 재시도
    func retryAfterRefresh(_ originalRequest: URLRequest) async throws -> Data {
        try await self.interceptor.refreshToken()

        var retryRequest = originalRequest
        retryRequest = self.interceptor.adapt(retryRequest)

        let (data, response) = try await execute(retryRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AppError.auth(.sessionExpired)
        }

        return data
    }

    func execute(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await self.session.data(for: request)
        } catch let error as URLError {
            throw NetworkErrorMapper.map(error)
        }
    }

    /// Response body의 "error" 필드에서 서버 에러 코드 파싱
    static func parseErrorCode(from data: Data) -> String {
        guard let json = try? JSONDecoder().decode([String: String].self, from: data),
              let code = json["error"] else {
            return ""
        }
        return code
    }

    func makeMultipartBody(imageData: Data, mimeType: String, boundary: String) -> Data {
        var body = Data()
        let crlf = "\r\n"
        let ext = mimeType.components(separatedBy: "/").last ?? "jpg"

        body.appendString("--\(boundary)\(crlf)")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"image.\(ext)\"\(crlf)")
        body.appendString("Content-Type: \(mimeType)\(crlf)")
        body.appendString(crlf)
        body.append(imageData)
        body.appendString(crlf)
        body.appendString("--\(boundary)--\(crlf)")

        return body
    }
}


// MARK: - Data + appendString

private extension Data {
    mutating func appendString(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.append(data)
    }
}
