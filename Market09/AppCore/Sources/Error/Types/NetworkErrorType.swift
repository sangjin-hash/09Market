//
//  NetworkErrorType.swift
//  AppCore
//
//  Created by Sangjin Lee
//

public enum NetworkErrorType: Equatable {

    // MARK: - 연결 관련

    case notConnected
    case timeout
    case cancelled
    case connectionLost
    case sslError

    // MARK: - HTTP 응답 관련

    case badRequest
    case conflict(ServerErrorCode)
    case rateLimited
    case notFound
    case serverError(statusCode: Int)
    case invalidResponse

    public var message: String {
        switch self {
        case .notConnected:
            return ErrorString.Network.notConnected
        case .timeout:
            return ErrorString.Network.timeout
        case .cancelled:
            return ""
        case .connectionLost:
            return ErrorString.Network.connectionLost
        case .sslError:
            return ErrorString.Network.sslError
        case .badRequest:
            return ""
        case .conflict(let code):
            return code.message
        case .rateLimited:
            return ErrorString.Network.rateLimited
        case .notFound:
            return ErrorString.Network.notFound
        case .serverError:
            return ErrorString.Network.serverError
        case .invalidResponse:
            return ErrorString.Network.invalidResponse
        }
    }
}
