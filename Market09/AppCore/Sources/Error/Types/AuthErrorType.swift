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
    case appleLoginFailed
    case rateLimited

    public var message: String {
        switch self {
        case .sessionExpired:
            return ErrorString.Auth.sessionExpired
        case .invalidCredentials:
            return ErrorString.Auth.invalidCredentials
        case .providerFailed:
            return ErrorString.Auth.providerFailed
        case .appleLoginFailed:
            return ErrorString.Auth.appleLoginFailed
        case .rateLimited:
            return ErrorString.Auth.rateLimited
        }
    }
}
