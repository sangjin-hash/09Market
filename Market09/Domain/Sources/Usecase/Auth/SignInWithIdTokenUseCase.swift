//
//  SignInWithIdTokenUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol SignInWithIdTokenUseCase {
    func execute(provider: String, idToken: String, nonce: String?) async throws -> AuthToken
}

public final class SignInWithIdTokenUseCaseImpl: SignInWithIdTokenUseCase {

    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(provider: String, idToken: String, nonce: String?) async throws -> AuthToken {
        try await authRepository.signInWithIdToken(
            provider: provider,
            idToken: idToken,
            nonce: nonce
        )
    }
}
