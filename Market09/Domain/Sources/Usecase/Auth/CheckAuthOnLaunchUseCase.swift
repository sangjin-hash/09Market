//
//  CheckAuthOnLaunchUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Core

public protocol CheckAuthOnLaunchUseCase {
    func execute() async throws -> AuthState
}

public final class CheckAuthOnLaunchUseCaseImpl: CheckAuthOnLaunchUseCase {
    
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    
    public init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    public func execute() async throws -> AuthState {
        // 1. 토큰 없음 → 익명 로그인
        if case .noToken = authRepository.currentTokenStatus() {
            _ = try await authRepository.signInAnonymously()
            return .anonymous
        }
        
        // 2. 토큰 있음 → GET /me (인터셉터가 토큰 주입 + 401 리프레시)
        do {
            if let user = try await userRepository.getMe() {
                return .authenticated(user)
            } else {
                return .anonymous
            }
        } catch let error as AppError where error.isRequireReAuth {
            // 3. 401 (리프레시도 실패)
            switch authRepository.currentTokenStatus() {
            case .valid(let isAnonymous), .expired(let isAnonymous):
                if isAnonymous {
                    _ = try await authRepository.signInAnonymously()
                    return .anonymous
                }
                
                try authRepository.clearToken()
                return .unauthenticated
                
            case .noToken:
                _ = try await authRepository.signInAnonymously()
                return .anonymous
            }
        }
    }
}
