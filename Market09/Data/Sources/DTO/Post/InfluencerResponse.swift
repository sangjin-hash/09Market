//
//  InfluencerResponse.swift
//  Data
//
//  Created by Sangjin Lee
//

struct InfluencerResponse: Decodable {
    let id: String
    let username: String
    let fullName: String
    let profilePicUrl: String
    let externalUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, username
        case fullName = "full_name"
        case profilePicUrl = "profile_pic_url"
        case externalUrl = "external_url"
    }
}
