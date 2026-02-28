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

// MARK: - Error Handle Strategy

extension AppError {

    public enum HandleStrategy {
        /// 재시도 가능한 에러 (재시도 버튼 포함 다이얼로그)
        case retryable(message: String)
        /// 사용자 안내가 필요한 에러 (확인 버튼만)
        case userGuide(message: String)
        /// 개발자 이슈 (assert)
        case developerError
        /// 로깅만 (UI 표시 없음)
        case silent
    }

    public var handleStrategy: HandleStrategy {
        switch self {
        // Retryable
        case .network(.notConnected),
             .network(.timeout),
             .network(.serverError):
            return .retryable(message: message)

        case .auth(.providerFailed),
             .auth(.rateLimited):
            return .retryable(message: message)

        // User Guide
        case .storage:
            return .userGuide(message: message)

        // Developer Error
        case .network(.notFound),
             .network(.invalidResponse):
            return .developerError

        // Silent
        case .unknown:
            return .silent

        // UseCase 내부에서 처리되지만, 혹시 Feature까지 올라온 경우 재시도 처리
        case .auth(.sessionExpired),
             .auth(.invalidCredentials):
            return .retryable(message: message)
        }
    }
}

// MARK: - Properties

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
