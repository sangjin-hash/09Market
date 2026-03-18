//
//  Post.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Foundation

public struct Post {
    public let id: String
    public let productName: String
    public let price: Int?
    public let category: GroupBuyingCategory
    public let imageUrls: [String]?
    public let groupBuyingStart: Date
    public let groupBuyingEnd: Date
    public let groupBuyingUrl: String?
    public var likesCount: Int
    public let postedAt: Date
    public let influencer: Influencer
    public var isLiked: Bool

    public init(
        id: String,
        productName: String,
        price: Int?,
        category: GroupBuyingCategory,
        imageUrls: [String]?,
        groupBuyingStart: Date,
        groupBuyingEnd: Date,
        groupBuyingUrl: String?,
        likesCount: Int,
        postedAt: Date,
        influencer: Influencer,
        isLiked: Bool
    ) {
        self.id = id
        self.productName = productName
        self.price = price
        self.category = category
        self.imageUrls = imageUrls
        self.groupBuyingStart = groupBuyingStart
        self.groupBuyingEnd = groupBuyingEnd
        self.groupBuyingUrl = groupBuyingUrl
        self.likesCount = likesCount
        self.postedAt = postedAt
        self.influencer = influencer
        self.isLiked = isLiked
    }

    /// 공구 상태 판단 (오픈 예정 / 진행중 / 마감임박 / 마감)
    public var groupBuyingStatus: GroupBuyingStatus {
        let now = Date()
        if now < self.groupBuyingStart {
            return .upcoming
        } else if now > self.groupBuyingEnd {
            return .closed
        } else if self.groupBuyingEnd.timeIntervalSince(now) < 24 * 60 * 60 {
            return .closingSoon
        } else {
            return .ongoing
        }
    }
}
