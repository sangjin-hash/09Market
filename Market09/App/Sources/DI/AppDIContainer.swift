//
//  AppDIContainer.swift
//  App
//
//  Created by Sangjin Lee
//

import Swinject

final class AppDIContainer {
    static let shared = AppDIContainer()

    private let assembler: Assembler

    var resolver: Resolver {
        assembler.resolver
    }

    private init() {
        assembler = Assembler([
            DataAssembly(),
            DomainAssembly(),
            PresentationAssembly(),
        ])
    }
}
