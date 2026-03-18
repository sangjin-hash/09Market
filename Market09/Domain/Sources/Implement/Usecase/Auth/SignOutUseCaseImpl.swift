//
//  SignOutUseCaseImpl.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import AppCore
import Domain

final class SignOutUseCaseImpl: SignOutUseCase {
    private let authRepository: AuthRepository
    private let userStore: UserStore

    init(authRepository: AuthRepository, userStore: UserStore) {
        self.authRepository = authRepository
        self.userStore = userStore
    }

    func execute(provider: AuthProvider) async throws {
        try await self.authRepository.signOut(provider: provider)
        try await self.authRepository.signInAnonymously()
        self.userStore.clear()
    }
}
