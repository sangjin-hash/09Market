//
//  Injected.swift
//  App
//
//  Created by Sangjin Lee
//

import Foundation

@propertyWrapper
struct Injected<T> {
    private var value: T

    var wrappedValue: T {
        get { value }
        mutating set { value = newValue }
    }

    init() {
        self.value = DIContainer.shared.resolve(T.self)
    }
}
