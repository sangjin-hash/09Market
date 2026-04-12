//
//  PostRepository.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol PostRepository {
    /// 공동구매 게시글 목록 조회
    /// - Parameters:
    ///   - page: 페이지 번호
    ///   - limit: 페이지당 개수
    ///   - search: 상품명 / 인플루언서 검색어
    ///   - category: 카테고리 필터
    ///   - dateFrom: 날짜 범위 시작 (YYYY-MM-DD)
    ///   - dateTo: 날짜 범위 끝 (YYYY-MM-DD)
    /// - Returns: 페이지네이션된 공동구매 게시글 목록
    func fetchPostsList(
        page: Int,
        limit: Int,
        search: String?,
        category: GroupBuyingCategory?,
        dateFrom: String?,
        dateTo: String?
    ) async throws -> Page<Post>
    
    /// 공동구매 게시글 등록
    /// - Parameters:
    ///   - request: PostCreateRequest
    /// - Returns: 페이지네이션된 공동구매 게시글 목록
    func createPost(_ post: Post) async throws -> Post

    /// 인기 공동구매 TOP 10
    /// - Returns: 최근 7일 내 좋아요 순 상위 10개 게시글
    func fetchTop10Posts() async throws -> [Post]
    
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
