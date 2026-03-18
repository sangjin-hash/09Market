//
//  AppCoordinator.swift
//  App
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import Authenticate
import Domain
import Home
import Login
import Profile
import Shared_DI

final class AppCoordinator: Coordinator {

    // MARK: - Coordinator Protocol

    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    

    // MARK: - Properties

    private enum LoginContext {
        case launch             // 앱 최초 실행 → 로그인 후 탭바 표시
        case profile            // 프로필 탭에서 요청 → 로그인 후 pop (이전 화면 복귀)
        case requireLogin       // 세션 만료 등 강제 → 로그인 후 pop + 제스처 복원
        case home               // 홈 화면에서 익명 로그인 상태에서 로그인이 필요한 서비스 이용 -> 로그인 후 home
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
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
        self.startAuth()
    }
}


// MARK: - Flow

private extension AppCoordinator {
    /// 앱 실행 시 인증/인가 작업 처리
    func startAuth() {
        let authCoordinator: AuthCoordinator = self.diContainer.resolver.resolve(argument: self.navigationController)

        authCoordinator.delegate = self
        self.addChild(authCoordinator)
        authCoordinator.start()
    }

    /// 홈 화면으로 이동
    func showTabBar() {
        let tabBarCoordinator = TabBarCoordinator(
            navigationController: self.navigationController,
            diContainer: self.diContainer,
            homeDelegate: self,
            profileDelegate: self
        )

        self.addChild(tabBarCoordinator)
        tabBarCoordinator.start()
    }

    /// 로그인 화면으로 이동
    func showLogin() {
        let loginCoordinator: LoginCoordinator = self.diContainer.resolver.resolve(argument: self.navigationController)

        loginCoordinator.delegate = self
        self.addChild(loginCoordinator)
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
            self.loginContext = .launch
            showLogin()
        }
    }
}


// MARK: - ProfileCoordinatorDelegate

extension AppCoordinator: ProfileCoordinatorDelegate {
    /// 프로필 탭에서 로그인 요청 시 로그인 화면으로 이동
    func profileDidRequestLogin() {
        self.loginContext = .profile
        showLogin()
    }

    /// 세션만료/인증실패로 강제 재인증 필요 (back 버튼 X, 스와이프 X)
    func profileDidRequireLogin() {
        self.loginContext = .requireLogin
        showLogin()
        self.navigationController.topViewController?.navigationItem.hidesBackButton = true
        self.navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }
}


// MARK: - LoginCoordinatorDelegate

extension AppCoordinator: LoginCoordinatorDelegate {
    /// 로그인 성공 시 진입 경로에 따라 분기 (launch: 탭바 표시, profile: 이전 화면으로 복귀)
    func loginDidComplete() {
        switch self.loginContext {
        case .launch:
            showTabBar()

        case .profile:
            self.navigationController.popViewController(animated: true)

        case .requireLogin:
            self.navigationController.interactivePopGestureRecognizer?.isEnabled = true
            self.navigationController.popViewController(animated: true)
            
        case .home:
            self.navigationController.popViewController(animated: true)

        case .none:
            break
        }

        self.loginContext = nil
    }
}


// MARK: - HomeCoordinatorDelegate

extension AppCoordinator: HomeCoordinatorDelegate {
    /// 익명로그인 상태에서 로그인이 필요한 서비스를 이용한 경우 -> 로그인 유도
    func homeDidRequestLogin() {
        self.loginContext = .home
        showLogin()
    }
}
