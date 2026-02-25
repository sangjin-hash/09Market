//
//  AuthMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import Domain

enum AuthMapper {
    
    /// AuthTokenResponse DTO -> AuthToken Entity
    static func toAuthTokenEntity(_ response: AuthTokenResponse) -> AuthToken {
        AuthToken(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
    }
}
