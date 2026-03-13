//
//  FetchTop10PostsUseCaseImpl.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import Domain

public final class FetchTop10PostsUseCaseImpl: FetchTop10PostsUseCase {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute() async throws -> [Post] {
        return try await self.postRepository.fetchTop10Posts()
    }
}
