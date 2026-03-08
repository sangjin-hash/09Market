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
        /// 재인증 필요 (확인 버튼 → 로그인 화면 이동)
        case requireLogin(message: String)
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
            return .retryable(message: self.message)

        case .auth(.providerFailed),
             .auth(.rateLimited):
            return .retryable(message: self.message)

        // User Guide
        case .storage:
            return .userGuide(message: self.message)

        // Developer Error
        case .network(.notFound),
             .network(.invalidResponse):
            return .developerError

        // Silent
        case .unknown:
            return .silent

        // 세션만료/인증실패 -> 로그인 화면 이동
        case .auth(.sessionExpired),
             .auth(.invalidCredentials):
            return .requireLogin(message: self.message)
        }
    }
}


// MARK: - Properties

extension AppError {
    public var isRequireReAuth: Bool {
        switch self {
        case .auth(.sessionExpired), .auth(.invalidCredentials):
            return true
        case .auth(.providerFailed), .auth(.rateLimited):
            return false
        case .network:
            return false
        case .storage:
            return false
        case .unknown:
            return false
        }
    }

    public var message: String {
        switch self {
        case .network(let type):
            return type.message
        case .auth(let type):
            return type.message
        case .storage(let type):
            return type.message
        case .unknown(let message):
            return message
        }
    }
}
