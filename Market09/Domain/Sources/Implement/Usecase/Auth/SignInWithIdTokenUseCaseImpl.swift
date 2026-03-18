//
//  SignInWithIdTokenUseCaseImpl.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import AppCore
import Domain

final class SignInWithIdTokenUseCaseImpl: SignInWithIdTokenUseCase {
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    private let userStore: UserStore

    init(
        authRepository: AuthRepository,
        userRepository: UserRepository,
        userStore: UserStore
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.userStore = userStore
    }

    func execute(provider: AuthProvider, idToken: String, nonce: String?) async throws -> AuthToken {
        let token = try await self.authRepository.signInWithIdToken(
            provider: provider,
            idToken: idToken,
            nonce: nonce
        )
        if let user = try await self.userRepository.fetchMe() {
            self.userStore.setUser(user)
        }
        return token
    }
}
