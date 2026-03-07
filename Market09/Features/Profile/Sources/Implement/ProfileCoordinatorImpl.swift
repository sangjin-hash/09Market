//
//  ProfileCoordinatorImpl.swift
//  ProfileImpl
//
//  Created by Sangjin Lee
//

import Core
import Profile
import Shared_ReactiveX
import UIKit

final class ProfileCoordinatorImpl: ProfileCoordinator {
    
    // MARK: - Coordinator Protocol

    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController

    
    // MARK: - Delegate

    public weak var delegate: ProfileCoordinatorDelegate?
    
    
    // MARK: - Reactor
    
    private let reactor: ProfileReactor
    private let disposeBag = DisposeBag()
    

    // MARK: - Init

    public init(navigationController: UINavigationController, reactor: ProfileReactor) {
        self.navigationController = navigationController
        self.reactor = reactor
    }
    

    // MARK: - Start

    public func start() {
        let viewController = ProfileViewController()
        viewController.reactor = reactor
        
        reactor.pulse(\.$loginRequested)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.profileDidRequestLogin()
            })
            .disposed(by: disposeBag)

        reactor.pulse(\.$loginRequired)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.profileDidRequireLogin()
            })
            .disposed(by: disposeBag)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
