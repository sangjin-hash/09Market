//
//  PostCreateRequest.swift
//  Data
//
//  Created by Sangjin Lee
//

struct PostCreateRequest: Encodable {
    let influencerId: String
    let displayUrl: String?
    let productName: String
    let price: Int
    let category: String
    let groupBuyingStart: String
    let groupBuyingEnd: String

    enum CodingKeys: String, CodingKey {
        case influencerId = "influencer_id"
        case displayUrl = "display_url"
        case productName = "product_name"
        case price
        case category
        case groupBuyingStart = "group_buying_start"
        case groupBuyingEnd = "group_buying_end"
    }
}
