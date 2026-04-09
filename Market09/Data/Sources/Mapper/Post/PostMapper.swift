//
//  PostMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import Domain

enum PostMapper {
    /// PostResponse -> PostEntity
    static func toPostEntity(_ response: PostResponse) -> Post {
        return Post(
            id: response.id,
            productName: response.productName,
            price: response.price,
            category: GroupBuyingCategory(rawValue: response.category) ?? .beauty,
            displayUrl: response.displayUrl,
            groupBuyingStart: dateFormatter.date(from: response.groupBuyingStart) ?? Date(),
            groupBuyingEnd: dateFormatter.date(from: response.groupBuyingEnd) ?? Date(),
            groupBuyingUrl: response.groupBuyingUrl,
            likesCount: response.likesCount,
            postedAt: dateFormatter.date(from: response.postedAt) ?? Date(),
            influencer: InfluencerMapper.toInfluencerEntity(response.influencer),
            isLiked: response.isLiked
        )
    }
    
    /// PostEntity -> PostCreateRequest
    static func toPostCreateRequest(_ post: Post) -> PostCreateRequest {
        return PostCreateRequest(
            influencerId: post.influencer.id,
            displayUrl: post.displayUrl,
            productName: post.productName,
            price: post.price ?? 0,
            category: post.category.rawValue,
            groupBuyingStart: requestDateFormatter.string(from: post.groupBuyingStart),
            groupBuyingEnd: requestDateFormatter.string(from: post.groupBuyingEnd)
        )
    }

    /// PageResponse -> PageEntity
    static func toPage(_ response: PageResponse<PostResponse>) -> Page<Post> {
        return Page(
            data: response.data.map(toPostEntity),
            total: response.total,
            page: response.page
        )
    }
    
    // MARK: - Private

    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let requestDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
