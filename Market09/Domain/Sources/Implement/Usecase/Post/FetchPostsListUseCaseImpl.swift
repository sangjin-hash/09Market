//
//  FetchPostsListUseCaseImpl.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import Domain

final class FetchPostsListUseCaseImpl: FetchPostsListUseCase {
    private let postRepository: PostRepository

    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    func execute(
        page: Int,
        limit: Int,
        search: String?,
        category: GroupBuyingCategory?,
        dateFrom: String?,
        dateTo: String?
    ) async throws -> Page<Post> {
        return try await self.postRepository.fetchPostsList(
            page: page,
            limit: limit,
            search: search,
            category: category,
            dateFrom: dateFrom,
            dateTo: dateTo
        )
    }
}
