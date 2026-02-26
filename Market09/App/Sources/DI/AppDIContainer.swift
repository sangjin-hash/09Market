//
//  AppDIContainer.swift
//  App
//
//  Created by Sangjin Lee
//

import Swinject
import HomeImpl
import Data
import Domain
import ProfileImpl
import AuthenticateImpl

final class AppDIContainer {
    static let shared = AppDIContainer()

    private let assembler: Assembler

    var resolver: Resolver {
        assembler.resolver
    }

    func resolve<T, Arg>(_ type: T.Type, argument: Arg) -> T? {
        assembler.resolver.resolve(type, argument: argument)
    }

    private init() {
        assembler = Assembler([
            DataAssembly(),
            DomainAssembly(),
            HomeAssembly(),
            ProfileAssembly(),
            AuthAssembly(),
        ])
    }
}
