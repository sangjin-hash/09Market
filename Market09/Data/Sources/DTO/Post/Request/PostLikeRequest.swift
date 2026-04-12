//
//  PostLikeRequest.swift
//  Data
//
//  Created by Sangjin Lee
//

struct PostLikeRequest: Encodable {
    let userId: String
    let postId: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case postId = "post_id"
    }
}
