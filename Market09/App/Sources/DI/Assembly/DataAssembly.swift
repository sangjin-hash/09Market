//
//  DataAssembly.swift
//  App
//
//  Created by Sangjin Lee
//

import Domain
import Data

struct DataAssembly: Assemblable {
    func assemble(container: DIContainer) {
        // TODO: RepositoryImpl, DataSource, APIClient 의존성 등록
//        container.register(GroupBuyRepository.self, scope: .singleton) {
//            GroupBuyRepositoryImpl()
//        }
    }
}
