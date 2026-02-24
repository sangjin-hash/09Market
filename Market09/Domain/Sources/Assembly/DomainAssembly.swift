//
//  DomainAssembly.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Swinject

public final class DomainAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        // TODO: UseCase 의존성 등록
//         container.register(FetchGroupBuyItemsUseCase.self) { resolver in
//             FetchGroupBuyItemsUseCase(
//                 repository: resolver.resolve(GroupBuyRepository.self)!
//             )
//         }
//         .inObjectScope(.container)
    }
}
