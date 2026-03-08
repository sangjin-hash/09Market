//
//  AuthToken.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Util

public struct AuthToken {
    public let accessToken: String
    public let refreshToken: String

    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    /// accessToken의 JWT exp claim을 검사하여 만료 여부 반환
    public var isExpired: Bool {
        return JWTDecoder.isExpired(self.accessToken)
    }
}
