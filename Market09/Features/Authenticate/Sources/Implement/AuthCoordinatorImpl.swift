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
        authReactor.state.map(\.authState)
            .compactMap { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.delegate?.authDidCheckOnLaunch(state: state)
            })
            .disposed(by: disposeBag)

        authReactor.state.map(\.error)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                ErrorDialog.show(
                    on: self.navigationController,
                    error: error,
                    retryAction: { self.authReactor.action.onNext(.checkAuth) }
                )
            })
            .disposed(by: disposeBag)

        authReactor.action.onNext(.checkAuth)
    }
}
