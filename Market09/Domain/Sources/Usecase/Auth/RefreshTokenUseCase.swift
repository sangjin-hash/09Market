//
//  RefreshTokenUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol RefreshTokenUseCase {
    func execute(refreshToken: String) async throws -> AuthToken
}

public final class RefreshTokenUseCaseImpl: RefreshTokenUseCase {

    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(refreshToken: String) async throws -> AuthToken {
        try await authRepository.refreshToken(refreshToken)
    }
}
