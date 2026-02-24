//
//  DataAssembly.swift
//  Data
//
//  Created by Sangjin Lee
//

import Swinject
import Domain

public final class DataAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        // TODO: RepositoryImpl, Client, DataSource 의존성 등록
//        container.register(GroupBuyRepository.self) { _ in
//            GroupBuyRepositoryImpl()
//        }
//        .inObjectScope(.container)
    }
}
