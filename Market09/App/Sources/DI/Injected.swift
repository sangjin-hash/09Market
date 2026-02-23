//
//  Injected.swift
//  App
//
//  Created by Sangjin Lee
//

import Swinject

@propertyWrapper
struct Injected<T> {
    private var value: T

    var wrappedValue: T {
        get { value }
        mutating set { value = newValue }
    }

    init() {
        self.value = AppDIContainer.shared.resolver.resolve(T.self)!
    }
}
