//
//  UserStore.swift
//  Core
//
//  Created by Sangjin Lee
//

import Shared_ReactiveX

public final class UserStore {
    public let currentUser = BehaviorRelay<User?>(value: nil)

    public var isLoggedIn: Bool {
        return self.currentUser.value != nil
    }

    public init() {}

    public func setUser(_ user: User) {
        self.currentUser.accept(user)
    }

    public func clear() {
        self.currentUser.accept(nil)
    }
}
