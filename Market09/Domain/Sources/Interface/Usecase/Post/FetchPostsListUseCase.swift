//
//  FetchPostsListUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol FetchPostsListUseCase {
    func execute(
        page: Int,
        limit: Int,
        search: String?,
        category: GroupBuyingCategory?,
        dateFrom: String?,
        dateTo: String?
    ) async throws -> Page<Post>
}
