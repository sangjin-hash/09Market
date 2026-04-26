//
//  TabBarCoordinator.swift
//  App
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import DesignSystem
import Home
import Schedule
import Profile
import Shared_DI

final class TabBarCoordinator: Coordinator {

    // MARK: - Coordinator Protocol

    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    
    // MARK: - Properties
    
    private let tabBarController: UITabBarController
    private let diContainer: AppDIContainer
    private weak var homeDelegate: HomeCoordinatorDelegate?
    private weak var profileDelegate: ProfileCoordinatorDelegate?


    // MARK: - Init

    init(
        navigationController: UINavigationController,
        diContainer: AppDIContainer,
        homeDelegate: HomeCoordinatorDelegate,
        profileDelegate: ProfileCoordinatorDelegate
    ) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
        self.diContainer = diContainer
        self.homeDelegate = homeDelegate
        self.profileDelegate = profileDelegate
    }
    
    
    // MARK: - Start
    
    func start() {
        let homeNav = UINavigationController()
        let scheduleNav = UINavigationController()
        let profileNav = UINavigationController()

        setupHomeTab(homeNav)
        setupScheduleTab(scheduleNav)
        setupProfileTab(profileNav)

        self.tabBarController.viewControllers = [homeNav, scheduleNav, profileNav]
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
        coordinator.delegate = self.homeDelegate
        addChild(coordinator)
        coordinator.start()
    }

    /// 스케쥴 탭 설정
    func setupScheduleTab(_ nav: UINavigationController) {
        nav.tabBarItem = UITabBarItem(title: "일정", image: UIImage(systemName: "calendar"), tag: 1)
        let coordinator: ScheduleCoordinator = self.diContainer.resolver.resolve(argument: nav)
        addChild(coordinator)
        coordinator.start()
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
