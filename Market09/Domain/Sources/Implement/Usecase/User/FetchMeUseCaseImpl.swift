//
//  FetchMeUseCaseImpl.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import AppCore
import Domain

final class FetchMeUseCaseImpl: FetchMeUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute() async throws -> User? {
        return try await self.userRepository.fetchMe()
    }
}
