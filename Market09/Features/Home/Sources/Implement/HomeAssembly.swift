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
        
        container.register(HomeCoordinator.self) { (r, navigationController: UINavigationController) in
            HomeCoordinatorImpl(
                navigationController: navigationController,
                homeViewController: r.resolve(HomeViewController.Factory.self)!.create(),
                homeTop10ViewController: r.resolve(HomeTop10ViewController.Factory.self)!.create()
            )
        }
        .inObjectScope(.graph)
    }
}
