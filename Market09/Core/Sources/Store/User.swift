//
//  User.swift
//  Core
//
//  Created by Sangjin Lee
//

public struct User {
    public let id: String
    public let nickname: String?
    public let profileUrl: String?
    public let provider: AuthProvider

    public init(id: String, nickname: String?, profileUrl: String?, provider: AuthProvider) {
        self.id = id
        self.nickname = nickname
        self.profileUrl = profileUrl
        self.provider = provider
    }
}
