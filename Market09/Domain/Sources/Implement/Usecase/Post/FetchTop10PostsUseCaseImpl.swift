//
//  FetchTop10PostsUseCaseImpl.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import Domain

final class FetchTop10PostsUseCaseImpl: FetchTop10PostsUseCase {
    private let postRepository: PostRepository

    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    func execute() async throws -> [Post] {
        return try await self.postRepository.fetchTop10Posts()
    }
}
