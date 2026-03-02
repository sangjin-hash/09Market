//
//  SignOutUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol SignOutUseCase {
    func execute() async throws
}

import Core

public final class SignOutUseCaseImpl: SignOutUseCase {

    private let authRepository: AuthRepository
    private let userStore: UserStore

    public init(authRepository: AuthRepository, userStore: UserStore) {
        self.authRepository = authRepository
        self.userStore = userStore
    }

    public func execute() async throws {
        try await authRepository.signOut()
        userStore.clear()
    }
}
