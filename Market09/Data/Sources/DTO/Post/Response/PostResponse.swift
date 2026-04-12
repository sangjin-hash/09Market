//
//  PostResponse.swift
//  Data
//
//  Created by Sangjin Lee
//

struct PostResponse: Decodable {
    let id: String
    let productName: String
    let price: Int?
    let category: String
    let displayUrl: String?
    let groupBuyingStart: String
    let groupBuyingEnd: String
    let groupBuyingUrl: String?
    let likesCount: Int
    let postedAt: String
    let influencer: InfluencerResponse
    let isLiked: Bool

    enum CodingKeys: String, CodingKey {
        case id, price, category, influencer
        case productName = "product_name"
        case displayUrl = "display_url"
        case groupBuyingStart = "group_buying_start"
        case groupBuyingEnd = "group_buying_end"
        case groupBuyingUrl = "group_buying_url"
        case likesCount = "likes_count"
        case postedAt = "posted_at"
        case isLiked = "is_liked"
    }
}
