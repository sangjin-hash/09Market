//
//  PostRepositoryImpl.swift
//  Data
//
//  Created by Sangjin Lee
//

import Domain

final class PostRepositoryImpl: PostRepository {
    private let remoteDataSource: PostRemoteDataSource

    init(remoteDataSource: PostRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchPostsList(
        page: Int,
        limit: Int,
        search: String?,
        category: GroupBuyingCategory?,
        dateFrom: String?,
        dateTo: String?
    ) async throws -> Page<Post> {
        let response = try await self.remoteDataSource.fetchPostsList(
            page: page,
            limit: limit,
            search: search,
            category: category?.rawValue,
            dateFrom: dateFrom,
            dateTo: dateTo
        )
        return PostMapper.toPage(response)
    }
    
    func createPost(_ post: Post) async throws -> Post {
        let request = PostMapper.toPostCreateRequest(post)
        let response = try await self.remoteDataSource.createPost(request)
        return PostMapper.toPostEntity(response)
    }

    func fetchTop10Posts() async throws -> [Post] {
        return try await self.remoteDataSource.fetchTop10Posts()
            .map(PostMapper.toPostEntity)
    }
    
    func likePost(userId: String, postId: String) async throws {
        return try await self.remoteDataSource.likePost(userId: userId, postId: postId)
    }

    func cancelLikePost(userId: String, postId: String) async throws {
        return try await self.remoteDataSource.cancelLikePost(userId: userId, postId: postId)
    }
}
