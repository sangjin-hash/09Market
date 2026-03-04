//
//  AppCoordinator.swift
//  App
//
//  Created by Sangjin Lee
//

import Authenticate
import Core
import Domain
import Login
import Profile
import UIKit

final class AppCoordinator: Coordinator {

    // MARK: - Coordinator Protocol

    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    

    // MARK: - Properties

    private enum LoginContext {
        case launch
        case profile
        case requireLogin
    }

    private let window: UIWindow
    private let diContainer: AppDIContainer
    private var loginContext: LoginContext?
    

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
    /// 앱 실행 시 인증/인가 작업 처리
    func startAuth() {
        let authCoordinator = diContainer.resolve(
            AuthCoordinator.self,
            argument: navigationController
        )!
        
        authCoordinator.delegate = self
        addChild(authCoordinator)
        authCoordinator.start()
    }

    /// 홈 화면으로 이동
    func showTabBar() {
        let tabBarCoordinator = TabBarCoordinator(
            navigationController: navigationController,
            diContainer: diContainer,
            profileDelegate: self
        )

        addChild(tabBarCoordinator)
        tabBarCoordinator.start()
    }

    /// 로그인 화면으로 이동
    func showLogin() {
        let loginCoordinator = diContainer.resolve(
            LoginCoordinator.self,
            argument: navigationController
        )!

        loginCoordinator.delegate = self
        addChild(loginCoordinator)
        loginCoordinator.start()
    }
}


// MARK: - AuthCoordinatorDelegate

extension AppCoordinator: AuthCoordinatorDelegate {
    /// 런치 시 인증 상태 확인 완료 후 분기 처리
    func authDidCheckOnLaunch(state: AuthState) {
        switch state {
        case .anonymous:
            showTabBar()
            
        case .authenticated:
            showTabBar()
            
        case .unauthenticated:
            loginContext = .launch
            showLogin()
        }
    }
}


// MARK: - ProfileCoordinatorDelegate

extension AppCoordinator: ProfileCoordinatorDelegate {
    /// 프로필 탭에서 로그인 요청 시 로그인 화면으로 이동
    func profileDidRequestLogin() {
        loginContext = .profile
        showLogin()
    }
    
    /// 세션만료/인증실패로 강제 재인증 필요 (back 버튼 X, 스와이프 X)
    func profileDidRequireLogin() {
        loginContext = .requireLogin
        showLogin()
        navigationController.topViewController?.navigationItem.hidesBackButton = true
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }
}


// MARK: - LoginCoordinatorDelegate

extension AppCoordinator: LoginCoordinatorDelegate {
    /// 로그인 성공 시 진입 경로에 따라 분기 (launch: 탭바 표시, profile: 이전 화면으로 복귀)
    func loginDidComplete() {
        switch loginContext {
        case .launch:
            showTabBar()
            
        case .profile:
            navigationController.popViewController(animated: true)
            
        case .requireLogin:
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            navigationController.popViewController(animated: true)
            
        case .none:
            break
        }
        
        loginContext = nil
    }
}
