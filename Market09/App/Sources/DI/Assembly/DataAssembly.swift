//
//  DataAssembly.swift
//  App
//
//  Created by Sangjin Lee
//

import Swinject
import Domain
import Data

final class DataAssembly: Assembly {
    func assemble(container: Container) {
        // TODO: RepositoryImpl, Client, DataSource 의존성 등록
//        container.register(GroupBuyRepository.self) { _ in
//            GroupBuyRepositoryImpl()
//        }
//        .inObjectScope(.container)
    }
}
