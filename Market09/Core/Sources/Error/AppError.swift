//
//  AppError.swift
//  Core
//
//  Created by Sangjin Lee
//

import Foundation

public enum AppError: Error, Equatable {
    case network(NetworkErrorType)
    case auth(AuthErrorType)
    case storage(StorageErrorType)
    case unknown(message: String)
}

extension AppError {

    public var isRequireReAuth: Bool {
        switch self {
        case .auth(.sessionExpired), .auth(.invalidCredentials):
            return true
        default:
            return false
        }
    }

    public var message: String {
        switch self {
        case .network(let type):    return type.message
        case .auth(let type):       return type.message
        case .storage(let type):    return type.message
        case .unknown(let message): return message
        }
    }
}
