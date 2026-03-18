//
//  DeleteAccountUseCaseImpl.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import AppCore
import Domain

final class DeleteAccountUseCaseImpl: DeleteAccountUseCase {
    private let authRepository: AuthRepository
    private let userStore: UserStore

    init(authRepository: AuthRepository, userStore: UserStore) {
        self.authRepository = authRepository
        self.userStore = userStore
    }

    // TODO: deleteAccount API 미구현 상태 — 현재 빈 호출 후 userStore만 clear됨
    func execute() async throws {
        try await self.authRepository.deleteAccount()
        self.userStore.clear()
    }
}
