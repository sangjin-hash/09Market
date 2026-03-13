//
//  PostRemoteDataSource.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import Core

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

    /// GET — 인기 공동구매 TOP 10
    /// - Returns: 최근 7일 내 좋아요 순 상위 10개 게시글
    func fetchTop10Posts() async throws -> [PostResponse]
}

final class PostRemoteDataSourceImpl: PostRemoteDataSource {
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

    func fetchTop10Posts() async throws -> [PostResponse] {
        return try await performRequest {
            let endpoint = self.postsEndpoint()
            let queryItems = [URLQueryItem(name: PostQueryKey.kAction, value: PostAction.kTop10)]
            let data = try await self.apiClient.get(endpoint, queryItems: queryItems)

            return try JSONDecoder().decode([PostResponse].self, from: data)
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

private enum PostAction {
    static let kList = "list"
    static let kTop10 = "top10"
}

extension PostRemoteDataSourceImpl {
    private func postsEndpoint() -> String {
        guard let endpoint = Bundle.main.infoDictionary?["API_POST"] as? String else {
            fatalError("API_POST가 Info.plist에 없습니다. Secrets.xcconfig을 확인하세요.")
        }
        return endpoint
    }

    @discardableResult
    private func performRequest<T>(_ operation: () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch let error as AppError {
            throw error
        } catch is DecodingError {
            throw AppError.network(.invalidResponse)
        } catch {
            throw AppError.unknown(message: error.localizedDescription)
        }
    }
}
