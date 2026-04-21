//
//  AuthCoordinatorImpl.swift
//  Authenticate
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import Authenticate
import Shared_ReactiveX

final class AuthCoordinatorImpl: AuthCoordinator {

    // MARK: - Coordinator Protocol

    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController
    
    
    // MARK: - Delegate
    
    public weak var delegate: AuthCoordinatorDelegate?
    
    
    // MARK: - Reactor
    
    private let authReactor: AuthReactor
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Init
    
    public init(
        navigationController: UINavigationController,
        authReactor: AuthReactor
    ) {
        self.navigationController = navigationController
        self.authReactor = authReactor
    }
    
    
    // MARK: - Launch the App

    public func start() {
        // 1. Splash 표시
        let viewController = AuthViewController()
        self.navigationController.setViewControllers([viewController], animated: false)

        // 2. authState 확정 시 delegate 호출
        self.authReactor.state.map(\.authState)
            .compactMap { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.delegate?.authDidCheckOnLaunch(state: state)
            })
            .disposed(by: self.disposeBag)

        // 3. 에러 시 ErrorHandler로 처리 (authVC 위에 표시)
        self.authReactor.state.map(\.error)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                ErrorHandler.handle(
                    error: error,
                    on: viewController,
                    action: { self.authReactor.action.onNext(.checkAuth) }
                )
            })
            .disposed(by: self.disposeBag)

        // 4. checkAuth 실행
        self.authReactor.action.onNext(.checkAuth)
    }
}
