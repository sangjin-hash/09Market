//
//  UserResponse.swift
//  Data
//
//  Created by Sangjin Lee
//

struct UserResponse: Decodable {
    let id: String
    let nickname: String?
    let profileUrl: String?
    let provider: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, nickname, provider
        case profileUrl = "profile_url"
        case createdAt = "created_at"
    }
}
