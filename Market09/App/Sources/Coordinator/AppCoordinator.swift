//
//  AppCoordinator.swift
//  App
//
//  Created by Sangjin Lee
//

import UIKit
import Core
import Home

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
        showHome()
    }
}

// MARK: - Flow

private extension AppCoordinator {

    func showHome() {
        let homeCoordinator = diContainer.resolve(
            HomeCoordinator.self,
            argument: navigationController
        )!
        homeCoordinator.delegate = self
        addChild(homeCoordinator)
        homeCoordinator.start()
    }
}

// MARK: - HomeCoordinatorDelegate

extension AppCoordinator: HomeCoordinatorDelegate {
    // MARK: - 실제 기능 구현 시 필요한 메서드 추가
    // func homeDidSelectProduct(_ productId: String) { }
    // func homeDidRequestFilter() { }
    // func homeDidRequestSafari(url: URL) { }
}
