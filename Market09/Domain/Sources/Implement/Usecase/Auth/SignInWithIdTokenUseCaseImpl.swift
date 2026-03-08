//
//  SignInWithIdTokenUseCaseImpl.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import Core
import Domain

public final class SignInWithIdTokenUseCaseImpl: SignInWithIdTokenUseCase {
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

    public func execute(provider: AuthProvider, idToken: String, nonce: String?) async throws -> AuthToken {
        let token = try await self.authRepository.signInWithIdToken(
            provider: provider,
            idToken: idToken,
            nonce: nonce
        )
        if let user = try await self.userRepository.getMe() {
            self.userStore.setUser(user)
        }
        return token
    }
}
