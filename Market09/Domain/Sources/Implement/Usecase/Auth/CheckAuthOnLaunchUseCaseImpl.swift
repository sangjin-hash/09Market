//
//  CheckAuthOnLaunchUseCaseImpl.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import Core
import Domain

public final class CheckAuthOnLaunchUseCaseImpl: CheckAuthOnLaunchUseCase {
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    private let userStore: UserStore

    public init(
        authRepository: AuthRepository,
        userRepository: UserRepository,
        userStore: UserStore
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.userStore = userStore
    }

    public func execute() async throws -> AuthState {
        // 1. 토큰 없음 → 익명 로그인
        if case .noToken = self.authRepository.currentTokenStatus() {
            _ = try await self.authRepository.signInAnonymously()
            self.userStore.clear()
            return .anonymous
        }

        // 2. 토큰 있음 → GET /me (인터셉터가 토큰 주입 + 401 리프레시)
        do {
            if let user = try await self.userRepository.getMe() {
                self.userStore.setUser(user)
                return .authenticated(user)
            } else {
                self.userStore.clear()
                return .anonymous
            }
        } catch let error as AppError where error.isRequireReAuth {
            // 3. 401 (리프레시도 실패)
            self.userStore.clear()
            switch self.authRepository.currentTokenStatus() {
            case .valid(let isAnonymous), .expired(let isAnonymous):
                if isAnonymous {
                    _ = try await self.authRepository.signInAnonymously()
                    return .anonymous
                }

                try self.authRepository.clearToken()
                return .unauthenticated

            case .noToken:
                _ = try await self.authRepository.signInAnonymously()
                return .anonymous
            }
        }
    }
}
