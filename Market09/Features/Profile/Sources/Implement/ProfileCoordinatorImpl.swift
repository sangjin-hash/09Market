//
//  ProfileCoordinatorImpl.swift
//  ProfileImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import Profile
import Shared_ReactiveX

final class ProfileCoordinatorImpl: ProfileCoordinator {
    
    // MARK: - Coordinator Protocol

    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController

    
    // MARK: - Delegate

    public weak var delegate: ProfileCoordinatorDelegate?
    
    
    // MARK: - Properties

    private let viewController: ProfileViewController
    private let disposeBag = DisposeBag()


    // MARK: - Init

    public init(navigationController: UINavigationController, viewController: ProfileViewController) {
        self.navigationController = navigationController
        self.viewController = viewController
    }


    // MARK: - Start

    public func start() {
        guard let reactor = self.viewController.reactor else { return }

        reactor.pulse(\.$loginRequested)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.profileDidRequestLogin()
            })
            .disposed(by: self.disposeBag)

        self.navigationController.setViewControllers([self.viewController], animated: false)
    }
}
