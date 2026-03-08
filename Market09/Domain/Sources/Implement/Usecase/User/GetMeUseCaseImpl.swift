//
//  GetMeUseCaseImpl.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import Core
import Domain

public final class GetMeUseCaseImpl: GetMeUseCase {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute() async throws -> User? {
        return try await self.userRepository.getMe()
    }
}
