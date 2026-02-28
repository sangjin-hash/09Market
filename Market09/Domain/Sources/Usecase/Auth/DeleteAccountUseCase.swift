//
//  DeleteAccountUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol DeleteAccountUseCase {
    func execute() async throws
}

import Core

public final class DeleteAccountUseCaseImpl: DeleteAccountUseCase {

    private let authRepository: AuthRepository
    private let userStore: UserStore

    public init(authRepository: AuthRepository, userStore: UserStore) {
        self.authRepository = authRepository
        self.userStore = userStore
    }

    public func execute() async throws {
        try await authRepository.deleteAccount()
        userStore.clear()
    }
}
