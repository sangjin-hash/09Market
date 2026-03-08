//
//  LoginCoordinatorImpl.swift
//  LoginImpl
//
//  Created by Sangjin Lee
//

import UIKit

import Core
import Login
import Shared_ReactiveX

final class LoginCoordinatorImpl: LoginCoordinator {

    // MARK: - Coordinator Protocol

    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController
    
    
    // MARK: - Delegate
    
    public weak var delegate: LoginCoordinatorDelegate?
    
    
    // MARK: - Reactor
    
    private let loginReactor: LoginReactor
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Init
    
    public init(
        navigationController: UINavigationController,
        loginReactor: LoginReactor
    ) {
        self.navigationController = navigationController
        self.loginReactor = loginReactor
    }
    
    
    // MARK: - Login
    
    public func start() {
        let viewController = LoginViewController()
        viewController.reactor = self.loginReactor

        // 로그인 성공 시 delegate 호출
        self.loginReactor.state.map(\.isLoginCompleted)
            .distinctUntilChanged()
            .filter { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.loginDidComplete()
            })
            .disposed(by: self.disposeBag)

        self.navigationController.pushViewController(viewController, animated: true)
    }
}
