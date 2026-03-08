//
//  AppDIContainer.swift
//  App
//
//  Created by Sangjin Lee
//

import AuthenticateImpl
import Data
import Domain
import DomainImpl
import HomeImpl
import LoginImpl
import ProfileImpl
import Shared_DI

final class AppDIContainer {
    static let shared = AppDIContainer()

    private let assembler: Assembler

    var resolver: Resolver {
        return self.assembler.resolver
    }

    private init() {
        self.assembler = Assembler([
            DataAssembly(),
            DomainAssembly(),
            
            AuthAssembly(),
            HomeAssembly(),
            LoginAssembly(),
            ProfileAssembly(),
        ])
    }
}
