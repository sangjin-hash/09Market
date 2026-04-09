//
//  NetworkErrorType.swift
//  Core
//
//  Created by Sangjin Lee
//

public enum NetworkErrorType: Equatable {
    case notConnected
    case timeout
    case notFound
    case conflict
    case serverError(statusCode: Int)
    case invalidResponse

    public var message: String {
        switch self {
        case .notConnected:
            return ErrorString.Network.notConnected
        case .timeout:
            return ErrorString.Network.timeout
        case .notFound:
            return ErrorString.Network.notFound
        case .conflict:
            return ErrorString.Network.conflict
        case .serverError:
            return ErrorString.Network.serverError
        case .invalidResponse:
            return ErrorString.Network.invalidResponse
        }
    }
}
