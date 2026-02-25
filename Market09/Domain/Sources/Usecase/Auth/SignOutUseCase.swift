//
//  SignOutUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol SignOutUseCase {
    func execute() async throws
}

public final class SignOutUseCaseImpl: SignOutUseCase {

    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute() async throws {
        try await authRepository.signOut()
    }
}
