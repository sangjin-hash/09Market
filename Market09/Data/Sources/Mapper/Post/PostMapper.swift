//
//  PostMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import Domain

enum PostMapper {
    static func toPostEntity(_ response: PostResponse) -> Post {
        return Post(
            id: response.id,
            productName: response.productName,
            price: response.price,
            category: Category(rawValue: response.category) ?? .beauty,
            imageUrls: response.imageUrls,
            groupBuyingStart: dateFormatter.date(from: response.groupBuyingStart) ?? Date(),
            groupBuyingEnd: dateFormatter.date(from: response.groupBuyingEnd) ?? Date(),
            groupBuyingUrl: response.groupBuyingUrl,
            likesCount: response.likesCount,
            postedAt: dateFormatter.date(from: response.postedAt) ?? Date(),
            influencer: toInfluencerEntity(response.influencer),
            isLiked: response.isLiked
        )
    }

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

    private static func toInfluencerEntity(_ response: InfluencerResponse) -> Influencer {
        return Influencer(
            id: response.id,
            username: response.username,
            fullName: response.fullName,
            profilePicUrl: response.profilePicUrl,
            externalUrl: response.externalUrl
        )
    }
}
