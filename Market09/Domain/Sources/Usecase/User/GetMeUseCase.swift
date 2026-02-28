//
//  GetMeUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol GetMeUseCase {
    func execute() async throws -> User?
}

public final class GetMeUseCaseImpl: GetMeUseCase {

    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute() async throws -> User? {
        try await userRepository.getMe()
    }
}
