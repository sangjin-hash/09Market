//
//  PostRemoteDataSource.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import AppCore

protocol PostRemoteDataSource {
    /// GET — 공동구매 게시글 목록 조회
    /// - Parameters:
    ///   - page: 페이지 번호 (기본값 1)
    ///   - limit: 페이지당 개수 (최대 50)
    ///   - search: 상품명 / 인플루언서 검색어
    ///   - category: 카테고리 필터
    ///   - dateFrom: 날짜 범위 시작 (YYYY-MM-DD)
    ///   - dateTo: 날짜 범위 끝 (YYYY-MM-DD)
    /// - Returns: 페이지네이션된 공동구매 게시글 목록
    func fetchPostsList(
        page: Int,
        limit: Int,
        search: String?,
        category: String?,
        dateFrom: String?,
        dateTo: String?
    ) async throws -> PageResponse<PostResponse>
    
    /// POST — 공동구매 게시글 등록
    /// - Parameters:
    ///   - request: PostCreateRequest
    /// - Returns: 페이지네이션된 공동구매 게시글 목록
    func createPost(_ request: PostCreateRequest) async throws -> PostResponse

    /// GET — 인기 공동구매 TOP 10
    /// - Returns: 최근 7일 내 좋아요 순 상위 10개 게시글
    func fetchTop10Posts() async throws -> [PostResponse]
    
    /// POST - 게시글 좋아요
    /// - Parameters:
    ///   - userId: 유저 ID(PK)
    ///   - postId: 해당 게시글 ID
    func likePost(userId: String, postId: String) async throws

    /// DELETE - 게시글 좋아요 취소
    /// - Parameters:
    ///   - userId: 유저 ID(PK)
    ///   - postId: 해당 게시글 ID
    func cancelLikePost(userId: String, postId: String) async throws

}

final class PostRemoteDataSourceImpl: PostRemoteDataSource, RemoteDataSource {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchPostsList(
        page: Int,
        limit: Int,
        search: String?,
        category: String?,
        dateFrom: String?,
        dateTo: String?
    ) async throws -> PageResponse<PostResponse> {
        return try await performRequest {
            let endpoint = self.postsEndpoint()

            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: PostQueryKey.kAction, value: PostAction.kList),
                URLQueryItem(name: PostQueryKey.kPage, value: String(page)),
                URLQueryItem(name: PostQueryKey.kLimit, value: String(limit))
            ]
            if let search, !search.isEmpty {
                queryItems.append(URLQueryItem(name: PostQueryKey.kSearch, value: search))
            }
            if let category, !category.isEmpty {
                queryItems.append(URLQueryItem(name: PostQueryKey.kCategory, value: category))
            }
            if let dateFrom, !dateFrom.isEmpty {
                queryItems.append(URLQueryItem(name: PostQueryKey.kDateFrom, value: dateFrom))
            }
            if let dateTo, !dateTo.isEmpty {
                queryItems.append(URLQueryItem(name: PostQueryKey.kDateTo, value: dateTo))
            }

            let data = try await self.apiClient.get(endpoint, queryItems: queryItems)
            return try JSONDecoder().decode(PageResponse<PostResponse>.self, from: data)
        }
    }
    
    func createPost(_ request: PostCreateRequest) async throws -> PostResponse {
        return try await performRequest {
            let endpoint = self.postsEndpoint()
            let queryItems = [URLQueryItem(name: PostQueryKey.kAction, value: PostAction.kCreate)]
            let body = try JSONEncoder().encode(request)
            
            let data = try await self.apiClient.post(endpoint, queryItems: queryItems, body: body)
            return try JSONDecoder().decode(PostResponse.self, from: data)
        }
    }

    func fetchTop10Posts() async throws -> [PostResponse] {
        return try await performRequest {
            let endpoint = self.postsEndpoint()
            let queryItems = [URLQueryItem(name: PostQueryKey.kAction, value: PostAction.kTop10)]
            let data = try await self.apiClient.get(endpoint, queryItems: queryItems)

            return try JSONDecoder().decode([PostResponse].self, from: data)
        }
    }
    
    func likePost(userId: String, postId: String) async throws {
        return try await performRequest {
            let endpoint = self.likeEndpoint()
            let body = try JSONEncoder().encode(PostLikeRequest(userId: userId, postId: postId))
            _ = try await self.apiClient.post(endpoint, body: body)
        }
    }
    
    func cancelLikePost(userId: String, postId: String) async throws {
        return try await performRequest {
            let endpoint = self.likeEndpoint()
            let queryItems = [
                URLQueryItem(name: LikeQueryKey.kUserId, value: "eq.\(userId)"),
                URLQueryItem(name: LikeQueryKey.kPostId, value: "eq.\(postId)"),
            ]
            try await self.apiClient.delete(endpoint, queryItems: queryItems)
        }
    }
}

private enum PostQueryKey {
    static let kAction = "action"
    static let kPage = "page"
    static let kLimit = "limit"
    static let kSearch = "search"
    static let kCategory = "category"
    static let kDateFrom = "date_from"
    static let kDateTo = "date_to"
}

private enum LikeQueryKey {
    static let kUserId = "user_id"
    static let kPostId = "post_id"
}

private enum PostAction {
    static let kList = "list"
    static let kTop10 = "top10"
    static let kCreate = "create"
}

extension PostRemoteDataSourceImpl {
    private func postsEndpoint() -> String {
        guard let endpoint = Bundle.main.infoDictionary?["API_POST"] as? String else {
            fatalError("API_POST가 Info.plist에 없습니다. Secrets.xcconfig을 확인하세요.")
        }
        return endpoint
    }
    
    private func likeEndpoint() -> String {
        guard let endpoint = Bundle.main.infoDictionary?["API_LIKE"] as? String else {
            fatalError("API_LIKE가 Info.plist에 없습니다. Secrets.xcconfig을 확인하세요.")
        }
        return endpoint
    }
}
