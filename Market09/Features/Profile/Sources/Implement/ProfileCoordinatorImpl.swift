//
//  ProfileCoordinatorImpl.swift
//  ProfileImpl
//
//  Created by Sangjin Lee
//

import UIKit
import Core
import Profile

final class ProfileCoordinatorImpl: ProfileCoordinator {
    
    // MARK: - Coordinator Protocol

    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController

    // MARK: - Delegate

    public weak var delegate: ProfileCoordinatorDelegate?
    
    // MARK: - Reactor
    
    private let reactor: ProfileReactor

    // MARK: - Init

    public init(navigationController: UINavigationController, reactor: ProfileReactor) {
        self.navigationController = navigationController
        self.reactor = reactor
    }

    // MARK: - Start

    public func start() {
        let viewController = ProfileViewController()
        viewController.reactor = reactor
        navigationController.setViewControllers([viewController], animated: false)
    }
}
