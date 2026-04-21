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
    case keychain(KeychainErrorType)
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
             .network(.connectionLost):
            return .retryable(message: self.message)

        // MARK: - User Guide

        case .client,
             .keychain(.saveFailed),
             .auth(.providerFailed),
             .auth(.rateLimited),
             .network(.rateLimited),
             .network(.serverError),
             .network(.conflict):
            return .userGuide(message: self.message)

        // MARK: - Require Login

        case .auth(.sessionExpired),
             .auth(.invalidCredentials),
             .keychain(.notFound):
            return .requireLogin(message: self.message)

        // MARK: - Developer Error

        case .network(.notFound),
             .network(.invalidResponse),
             .network(.badRequest),
             .network(.sslError):
            return .developerError

        // MARK: - Silent

        case .network(.cancelled),
             .keychain(.loadFailed),
             .keychain(.deleteFailed),
             .unknown:
            return .silent
        }
    }
}


// MARK: - Properties

extension AppError {
    /// 앱 실행 시 인증/인가 과정에서 재인증 관련 로직 처리할 때 사용되는 분기
    public var isRequireReAuth: Bool {
        return self == .auth(.sessionExpired) || self == .auth(.invalidCredentials)
    }

    public var message: String {
        switch self {
        case .client(let type):
            return type.message
        case .network(let type):
            return type.message
        case .auth(let type):
            return type.message
        case .keychain(let type):
            return type.message
        case .unknown(let message):
            return message
        }
    }
}
