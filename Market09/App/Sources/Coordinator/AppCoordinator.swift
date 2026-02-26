//
//  AppCoordinator.swift
//  App
//
//  Created by Sangjin Lee
//

import UIKit
import Core
import Domain
import Authenticate

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
        startAuth()
    }
}

// MARK: - Flow

private extension AppCoordinator {
    
    func startAuth() {
        let authCoordinator = diContainer.resolve(AuthCoordinator.self, argument: navigationController)!
        authCoordinator.delegate = self
        addChild(authCoordinator)
        authCoordinator.start()
    }

    func showTabBar() {
        let tabBarCoordinator = TabBarCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )
        addChild(tabBarCoordinator)
        tabBarCoordinator.start()
    }
}

// MARK: - AuthCoordinatorDelegate
extension AppCoordinator: AuthCoordinatorDelegate {
    
    func authDidCheckOnLaunch(state: AuthState) {
        switch state {
        case .anonymous, .authenticated:
            showTabBar()
        case .unauthenticated:
            // TODO: 소셜 재로그인 화면 표시
            showTabBar()
        }
    }
    
    func authDidLogin() {
        navigationController.dismiss(animated: true)
    }
    
    func authDidCancelLogin() {
        navigationController.dismiss(animated: true)
    }
}
