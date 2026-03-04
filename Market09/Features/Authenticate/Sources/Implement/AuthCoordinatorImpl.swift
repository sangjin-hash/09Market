//
//  AuthCoordinatorImpl.swift
//  Authenticate
//
//  Created by Sangjin Lee
//

import Authenticate
import Core
import UIKit

import RxCocoa
import RxSwift

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
    
    
    // MARK: - Launch the App(Splash)
    
    public func start() {
        // 1. SplashViewController 표시
        let splashVC = SplashViewController()
        navigationController.setViewControllers([splashVC], animated: false)

        // 2. authState 확정 시 delegate 호출
        authReactor.state.map(\.authState)
            .compactMap { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.delegate?.authDidCheckOnLaunch(state: state)
            })
            .disposed(by: disposeBag)

        // 3. 에러 시 ErrorDialog 표시 (splashVC 위에 표시)
        authReactor.state.map(\.error)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                ErrorDialog.show(
                    on: splashVC,
                    error: error,
                    retryAction: { self.authReactor.action.onNext(.checkAuth) }
                )
            })
            .disposed(by: disposeBag)

        // 4. checkAuth 실행
        authReactor.action.onNext(.checkAuth)
    }
}
