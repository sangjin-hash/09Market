//
//  CreatePostUseCaseImpl.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Domain

final class CreatePostUseCaseImpl: CreatePostUseCase {
    private let postRepository: PostRepository
    
    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }
    
    func execute(_ post: Post) async throws -> Post {
        return try await self.postRepository.createPost(post)
    }
}
