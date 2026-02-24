//
//  HomeCoordinatorImpl.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit
import Core
import Home

public final class HomeCoordinatorImpl: HomeCoordinator {

    // MARK: - Coordinator Protocol

    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController

    // MARK: - HomeCoordinator Protocol

    public weak var delegate: HomeCoordinatorDelegate?

    // MARK: - Init

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Start

    public func start() {
        // TODO: ViewController 생성 및 push
    }
}
