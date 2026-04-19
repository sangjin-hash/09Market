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
        
        container.register(HomeTop10Reactor.Factory.self) { r in
            HomeTop10Reactor.Factory(dependency: .init(
                fetchTop10PostsUseCase: r.resolve()
            ))
        }
        .inObjectScope(.graph)
        
        container.register(HomeTop10ViewController.Factory.self) { r in
            HomeTop10ViewController.Factory(dependency: .init(
                reactor: r.resolve(HomeTop10Reactor.Factory.self)!.create()
            ))
        }
        .inObjectScope(.graph)
        
        container.register(HomeCreatePostReactor.Factory.self) { r in
            HomeCreatePostReactor.Factory(dependency: .init(
                searchInfluencersUseCase: r.resolve(),
                uploadImageUseCase: r.resolve(),
                createPostUseCase: r.resolve()
            ))
        }
        .inObjectScope(.graph)
        
        container.register(HomeCreatePostViewController.Factory.self) { r in
            HomeCreatePostViewController.Factory(dependency: .init(
                reactor: r.resolve(HomeCreatePostReactor.Factory.self)!.create()
            ))
        }
        .inObjectScope(.graph)

        container.register(HomeTop10Coordinator.self) { (r, navigationController: UINavigationController) in
            HomeTop10CoordinatorImpl(
                navigationController: navigationController,
                viewController: r.resolve(HomeTop10ViewController.Factory.self)!.create()
            )
        }
        .inObjectScope(.graph)

        container.register(HomeCreatePostCoordinator.self) { (r, navigationController: UINavigationController) in
            HomeCreatePostCoordinatorImpl(
                navigationController: navigationController,
                viewController: r.resolve(HomeCreatePostViewController.Factory.self)!.create()
            )
        }
        .inObjectScope(.graph)

        container.register(HomeCoordinator.self) { (r, navigationController: UINavigationController) in
            HomeCoordinatorImpl(
                navigationController: navigationController,
                homeViewController: r.resolve(HomeViewController.Factory.self)!.create(),
                resolver: r
            )
        }
        .inObjectScope(.graph)
    }
}
