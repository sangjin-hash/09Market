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
    public let provider: String

    public init(id: String, nickname: String?, profileUrl: String?, provider: String) {
        self.id = id
        self.nickname = nickname
        self.profileUrl = profileUrl
        self.provider = provider
    }
}
