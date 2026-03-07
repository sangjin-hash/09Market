//
//  LoginCoordinatorImpl.swift
//  LoginImpl
//
//  Created by Sangjin Lee
//

import Core
import Login
import Shared_ReactiveX
import UIKit

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
        viewController.reactor = loginReactor
        
        // 로그인 성공 시 delegate 호출
        loginReactor.state.map(\.isLoginCompleted)
            .distinctUntilChanged()
            .filter { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.loginDidComplete()
            })
            .disposed(by: disposeBag)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
