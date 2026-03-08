//
//  TabBarCoordinator.swift
//  App
//
//  Created by Sangjin Lee
//

import UIKit

import Core
import Home
import Profile
import Shared_DI
import Util

final class TabBarCoordinator: Coordinator {

    // MARK: - Coordinator Protocol

    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    
    // MARK: - Properties
    
    private let tabBarController: UITabBarController
    private let diContainer: AppDIContainer
    private weak var profileDelegate: ProfileCoordinatorDelegate?
    
    
    // MARK: - Init
    
    init(
        navigationController: UINavigationController,
        diContainer: AppDIContainer,
        profileDelegate: ProfileCoordinatorDelegate
    ) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
        self.diContainer = diContainer
        self.profileDelegate = profileDelegate
    }
    
    
    // MARK: - Start
    
    func start() {
        let homeNav = UINavigationController()
        // TODO: 추후 기획 후 해당 Nav 변경할 것
        let tempNav = UINavigationController()
        let profileNav = UINavigationController()

        setupHomeTab(homeNav)
        setupTempTab(tempNav)
        setupProfileTab(profileNav)

        self.tabBarController.viewControllers = [homeNav, tempNav, profileNav]
        self.navigationController.setViewControllers([self.tabBarController], animated: false)
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
}


// MARK: - Tab Setup

private extension TabBarCoordinator {
    /// 홈 탭 설정
    func setupHomeTab(_ nav: UINavigationController) {
        nav.tabBarItem = UITabBarItem(title: Strings.Tab.home, image: UIImage(systemName: "house"), tag: 0)
        let coordinator: HomeCoordinator = self.diContainer.resolver.resolve(argument: nav)
        addChild(coordinator)
        coordinator.start()
    }

    // TODO: 추후 기획 후 Coordinator 변경할 것
    func setupTempTab(_ nav: UINavigationController) {
        nav.tabBarItem = UITabBarItem(title: Strings.Tab.temp, image: UIImage(systemName: "square.grid.2x2"), tag: 1)
        // TODO: TempCoordinator 연결
        let placeholder = UIViewController()
        placeholder.view.backgroundColor = .systemBackground
        nav.setViewControllers([placeholder], animated: false)
    }

    /// 프로필 탭 설정 및 delegate 연결
    func setupProfileTab(_ nav: UINavigationController) {
        nav.tabBarItem = UITabBarItem(title: Strings.Tab.profile, image: UIImage(systemName: "person"), tag: 2)
        let coordinator: ProfileCoordinator = self.diContainer.resolver.resolve(argument: nav)
        coordinator.delegate = self.profileDelegate
        addChild(coordinator)
        coordinator.start()
    }
}
