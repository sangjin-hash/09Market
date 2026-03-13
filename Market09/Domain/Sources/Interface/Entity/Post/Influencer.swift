//
//  Influencer.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Foundation

public struct Influencer {
    public let id: String
    public let username: String
    public let fullName: String
    public let profilePicUrl: String
    public let externalUrl: String?

    public init(
        id: String,
        username: String,
        fullName: String,
        profilePicUrl: String,
        externalUrl: String?
    ) {
        self.id = id
        self.username = username
        self.fullName = fullName
        self.profilePicUrl = profilePicUrl
        self.externalUrl = externalUrl
    }

    public var instagramProfileURL: URL? {
        return URL(string: "https://www.instagram.com/" + self.username)
    }
}
