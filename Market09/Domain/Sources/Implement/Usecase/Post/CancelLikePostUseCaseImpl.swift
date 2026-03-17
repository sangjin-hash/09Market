//
//  CancelLikePostUseCaseImpl.swift
//  Domain
//
//  Created by Sangjin Lee
//

import AppCore
import Domain

final class CancelLikePostUseCaseImpl: CancelLikePostUseCase {
    private let postRepository: PostRepository
    private let userStore: UserStore
    
    init(postRepository: PostRepository, userStore: UserStore) {
        self.postRepository = postRepository
        self.userStore = userStore
    }
    
    func execute(postId: String) async throws {
        guard let user = self.userStore.currentUser.value else {
            return
        }
        
        let userId = user.id
        return try await self.postRepository.cancelLikePost(userId: userId, postId: postId)
    }
}
