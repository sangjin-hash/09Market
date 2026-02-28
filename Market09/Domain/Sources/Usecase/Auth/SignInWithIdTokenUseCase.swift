//
//  SignInWithIdTokenUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Core

public protocol SignInWithIdTokenUseCase {
    func execute(provider: String, idToken: String, nonce: String?) async throws -> AuthToken
}

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

    public func execute(provider: String, idToken: String, nonce: String?) async throws -> AuthToken {
        let token = try await authRepository.signInWithIdToken(
            provider: provider,
            idToken: idToken,
            nonce: nonce
        )
        if let user = try await userRepository.getMe() {
            userStore.setUser(user)
        }
        return token
    }
}
