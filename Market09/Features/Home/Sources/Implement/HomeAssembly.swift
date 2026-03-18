//
//  HomeAssembly.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import Home
import Shared_DI

public final class HomeAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(HomeReactor.Factory.self) { r in
            HomeReactor.Factory(dependency: .init(
                fetchPostsListUseCase: r.resolve(),
                fetchTop10PostsUseCase: r.resolve(),
                likePostUseCase: r.resolve(),
                cancelLikePostUseCase: r.resolve(),
                userStore: r.resolve()
            ))
        }
        .inObjectScope(.graph)
        
        container.register(HomeViewController.Factory.self) { r in
            HomeViewController.Factory(dependency: .init(
                reactor: r.resolve(HomeReactor.Factory.self)!.create()
            ))
        }
        .inObjectScope(.graph)
        
        container.register(HomeCoordinator.self) { (r, navigationController: UINavigationController) in
            HomeCoordinatorImpl(
                navigationController: navigationController,
                viewController: r.resolve(HomeViewController.Factory.self)!.create()
            )
        }
        .inObjectScope(.graph)
    }
}
