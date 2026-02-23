//
//  AppCoordinator.swift
//  App
//
//  Created by Sangjin Lee
//

import UIKit

final class AppCoordinator: Coordinator {

    // MARK: - Coordinator Protocol

    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController

    // MARK: - Properties

    private let window: UIWindow
    private let diContainer: AppDIContainer

    // MARK: - Init

    init(window: UIWindow, diContainer: AppDIContainer) {
        self.window = window
        self.diContainer = diContainer
        self.navigationController = UINavigationController()
    }

    // MARK: - Start

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        navigate(to: .home)
    }
}

// MARK: - Route

extension AppCoordinator {

    enum Route {
        case home
    }

    func navigate(to route: Route) {
        switch route {
        case .home:
            showHome()
        }
    }
}

// MARK: - Flow

private extension AppCoordinator {

    func showHome() {
        let homeCoordinator = HomeCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )
        homeCoordinator.onFinished = { [weak self, weak homeCoordinator] in
            guard let homeCoordinator else { return }
            self?.removeChild(homeCoordinator)
        }
        addChild(homeCoordinator)
        homeCoordinator.start()
    }
}
