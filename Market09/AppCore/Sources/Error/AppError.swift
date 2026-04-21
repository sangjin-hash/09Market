//
//  AppError.swift
//  AppCore
//
//  Created by Sangjin Lee
//

import Foundation

public enum AppError: Error, Equatable {
    case client(ClientErrorType)
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

        // MARK: - Retryable

        case .network(.notConnected),
             .network(.timeout),
             .network(.connectionLost),
             .network(.rateLimited),
             .network(.serverError):
            return .retryable(message: self.message)

        case .auth(.providerFailed),
             .auth(.rateLimited):
            return .retryable(message: self.message)

        // MARK: - User Guide

        case .client:
            return .userGuide(message: self.message)

        case .storage:
            return .userGuide(message: self.message)

        case .network(.conflict),
             .network(.sslError):
            return .userGuide(message: self.message)

        // MARK: - Require Login

        case .auth(.sessionExpired),
             .auth(.invalidCredentials):
            return .requireLogin(message: self.message)

        // MARK: - Developer Error

        case .network(.notFound),
             .network(.invalidResponse),
             .network(.badRequest):
            return .developerError

        // MARK: - Silent

        case .network(.cancelled),
             .unknown:
            return .silent
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
        case .client:
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
        case .client(let type):
            return type.message
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
