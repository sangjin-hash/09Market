//
//  AuthCoordinatorImpl.swift
//  Authenticate
//
//  Created by Sangjin Lee
//

import UIKit
import RxSwift
import RxCocoa
import Core
import Authenticate

final class AuthCoordinatorImpl: AuthCoordinator {
    
    // MARK: - Coordinator Protocol
    
    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController
    
    // MARK: - Delegate
    
    public weak var delegate: AuthCoordinatorDelegate?
    
    // MARK: - Reactor
    
    private let launchAuthReactor: LaunchAuthReactor
    private let loginReactor: LoginReactor
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Init
    
    public init(
        navigationController: UINavigationController,
        launchAuthReactor: LaunchAuthReactor,
        loginReactor: LoginReactor
    ) {
        self.navigationController = navigationController
        self.launchAuthReactor = launchAuthReactor
        self.loginReactor = loginReactor
    }
    
    // MARK: - Launch the App(Splash)
    
    public func start() {
        launchAuthReactor.state.map(\.authState)
            .compactMap { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.delegate?.authDidCheckOnLaunch(state: state)
            })
            .disposed(by: disposeBag)

        launchAuthReactor.state.map(\.error)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                ErrorDialog.show(
                    on: self.navigationController,
                    error: error,
                    retryAction: { self.launchAuthReactor.action.onNext(.checkAuth) }
                )
            })
            .disposed(by: disposeBag)

        launchAuthReactor.action.onNext(.checkAuth)
    }
    
    // MARK: - Login
    
    public func showLogin() {
        let viewController = LoginViewController()
        viewController.reactor = loginReactor
        
        // 로그인 성공 시 delegate 호출
        loginReactor.state.map(\.isLoginCompleted)
            .distinctUntilChanged()
            .filter { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.authDidLogin()
            })
            .disposed(by: disposeBag)
        
        navigationController.present(
            UINavigationController(rootViewController: viewController),
            animated: false
        )
    }
    
}
