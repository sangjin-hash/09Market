//
//  DeleteAccountUseCaseImpl.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import Core
import Domain

public final class DeleteAccountUseCaseImpl: DeleteAccountUseCase {

    private let authRepository: AuthRepository
    private let userStore: UserStore

    public init(authRepository: AuthRepository, userStore: UserStore) {
        self.authRepository = authRepository
        self.userStore = userStore
    }

    // TODO: deleteAccount API 미구현 상태 — 현재 빈 호출 후 userStore만 clear됨
    public func execute() async throws {
        try await authRepository.deleteAccount()
        userStore.clear()
    }
}
