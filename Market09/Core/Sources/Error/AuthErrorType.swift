//
//  AuthErrorType.swift
//  Core
//
//  Created by Sangjin Lee
//

public enum AuthErrorType: Equatable {
    case sessionExpired
    case invalidCredentials
    case providerFailed
    case rateLimited

    public var message: String {
        switch self {
        case .sessionExpired:     return ErrorString.Auth.sessionExpired
        case .invalidCredentials: return ErrorString.Auth.invalidCredentials
        case .providerFailed:     return ErrorString.Auth.providerFailed
        case .rateLimited:        return ErrorString.Auth.rateLimited
        }
    }
}
