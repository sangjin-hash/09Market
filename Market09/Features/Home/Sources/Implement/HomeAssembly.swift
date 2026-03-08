//
//  HomeAssembly.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import Core
import Home
import Shared_DI

public final class HomeAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(HomeCoordinator.self) { (_, navigationController: UINavigationController) in
            HomeCoordinatorImpl(navigationController: navigationController)
        }
    }
}
