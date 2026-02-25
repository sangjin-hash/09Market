//
//  DeleteAccountUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol DeleteAccountUseCase {
    func execute() async throws
}

public final class DeleteAccountUseCaseImpl: DeleteAccountUseCase {

    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute() async throws {
        try await authRepository.deleteAccount()
    }
}
