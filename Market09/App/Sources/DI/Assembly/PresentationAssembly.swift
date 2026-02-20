//
//  PresentationAssembly.swift
//  App
//
//  Created by Sangjin Lee
//

import Domain
// import 각 Feature들

struct PresentationAssembly: Assemblable {
    func assemble(container: DIContainer) {
        // TODO: 향후 ViewModel 등록
//        container.register(GroupBuyListViewModel.self, scope: .transient) {
//            GroupBuyListViewModel(
//                useCase: container.resolve(FetchGroupBuyItemsUseCase.self)
//            )
//        }
    }
}
