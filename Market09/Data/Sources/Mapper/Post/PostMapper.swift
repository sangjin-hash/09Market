//
//  PostMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import Domain
import Util

enum PostMapper {
    /// PostResponse -> PostEntity
    static func toPostEntity(_ response: PostResponse) -> Post {
        return Post(
            id: response.id,
            productName: response.productName,
            price: response.price,
            category: GroupBuyingCategory(rawValue: response.category) ?? .beauty,
            displayUrl: response.displayUrl,
            groupBuyingStart: Formatters.iso8601.date(from: response.groupBuyingStart) ?? Date(),
            groupBuyingEnd: Formatters.iso8601.date(from: response.groupBuyingEnd) ?? Date(),
            groupBuyingUrl: response.groupBuyingUrl,
            likesCount: response.likesCount,
            postedAt: Formatters.iso8601.date(from: response.postedAt) ?? Date(),
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
            groupBuyingStart: Formatters.iso8601Request.string(from: post.groupBuyingStart),
            groupBuyingEnd: Formatters.iso8601Request.string(from: post.groupBuyingEnd)
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
    
}
