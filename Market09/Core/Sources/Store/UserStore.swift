//
//  UserStore.swift
//  Core
//
//  Created by Sangjin Lee
//

import RxRelay

public final class UserStore {
    public let currentUser = BehaviorRelay<User?>(value: nil)

    public var isLoggedIn: Bool { currentUser.value != nil }

    public init() {}

    public func setUser(_ user: User) {
        currentUser.accept(user)
    }

    public func clear() {
        currentUser.accept(nil)
    }
}
