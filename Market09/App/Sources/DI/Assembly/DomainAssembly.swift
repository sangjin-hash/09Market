//
//  DomainAssembly.swift
//  App
//
//  Created by Sangjin Lee
//

import Domain

struct DomainAssembly: Assemblable {
    func assemble(container: DIContainer) {
        // TODO: Usecase 의존성 등록
//        container.register(FetchGroupBuyItemsUseCase.self, scope: .singleton) {
//            FetchGroupBuyItemsUseCase(
//                repository: container.resolve(GroupBuyRepository.self)
//            )
//        }
    }
}
