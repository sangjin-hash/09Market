//
//  SignInAnonymouslyUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol SignInAnonymouslyUseCase {
    func execute() async throws -> AuthToken
}

public final class SignInAnonymouslyUseCaseImpl: SignInAnonymouslyUseCase {

    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute() async throws -> AuthToken {
        try await authRepository.signInAnonymously()
    }
}
