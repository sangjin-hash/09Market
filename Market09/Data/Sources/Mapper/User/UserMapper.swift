//
//  UserMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import Core

enum UserMapper {
    static func toUserEntity(_ response: UserResponse) -> User {
        User(
            id: response.id,
            nickname: response.nickname,
            profileUrl: response.profileUrl,
            provider: response.provider
        )
    }
}
