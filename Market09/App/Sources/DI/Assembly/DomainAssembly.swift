//
//  DomainAssembly.swift
//  App
//
//  Created by Sangjin Lee
//

import Swinject
import Domain

final class DomainAssembly: Assembly {
    func assemble(container: Container) {
        // TODO: UseCase 의존성 등록
//         container.register(FetchGroupBuyItemsUseCase.self) { resolver in
//             FetchGroupBuyItemsUseCase(
//                 repository: resolver.resolve(GroupBuyRepository.self)!
//             )
//         }
//         .inObjectScope(.container)
    }
}
