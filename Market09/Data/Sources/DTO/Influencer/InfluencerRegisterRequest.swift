//
//  InfluencerRegisterRequest.swift
//  Data
//
//  Created by Sangjin Lee
//

struct InfluencerRegisterRequest: Encodable {
    let instagramUsername: String

    enum CodingKeys: String, CodingKey {
        case instagramUsername = "instagram_username"
    }
}
