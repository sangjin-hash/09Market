//
//  PresentationAssembly.swift
//  App
//
//  Created by Sangjin Lee
//

import Swinject
import Domain
// import 각 Feature들

final class PresentationAssembly: Assembly {
    func assemble(container: Container) {
        // TODO: ViewModel 의존성 등록
        // container.register(GroupBuyListViewModel.self) { resolver in
        //     GroupBuyListViewModel(
        //         useCase: resolver.resolve(FetchGroupBuyItemsUseCase.self)!
        //     )
        // }
        // .inObjectScope(.transient)
    }
}
