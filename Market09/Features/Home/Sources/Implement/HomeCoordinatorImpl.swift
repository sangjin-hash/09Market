//
//  HomeCoordinatorImpl.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import Home
import Shared_DI
import Shared_ReactiveX

final class HomeCoordinatorImpl: HomeCoordinator {

    // MARK: - Coordinator Protocol

    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController


    // MARK: - Delegate

    public weak var delegate: HomeCoordinatorDelegate?
    
    
    // MARK: - Reactor
    
    private let viewController: HomeViewController
    private let disposeBag = DisposeBag()


    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        viewController: HomeViewController
    ) {
        self.navigationController = navigationController
        self.viewController = viewController
    }


    // MARK: - Start

    public func start() {
        guard let reactor = self.viewController.reactor else { return }
        
        reactor.pulse(\.$loginConfirmed)
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.homeDidRequestLogin()
            })
            .disposed(by: self.disposeBag)
        
        self.navigationController.pushViewController(self.viewController, animated: true)
    }
}
