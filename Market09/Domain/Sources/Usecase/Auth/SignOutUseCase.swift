//
//  SignOutUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol SignOutUseCase {
    func execute(provider: AuthProvider) async throws
}

import Core

public final class SignOutUseCaseImpl: SignOutUseCase {

    private let authRepository: AuthRepository
    private let userStore: UserStore

    public init(authRepository: AuthRepository, userStore: UserStore) {
        self.authRepository = authRepository
        self.userStore = userStore
    }

    public func execute(provider: AuthProvider) async throws {
        try await authRepository.signOut(provider: provider)
        try await authRepository.signInAnonymously()
        userStore.clear()
    }
}
