//
//  ScheduleCoordinatorImpl.swift
//  ScheduleImpl
//

import UIKit

import AppCore
import Schedule
import Shared_DI

final class ScheduleCoordinatorImpl: ScheduleCoordinator {

    // MARK: - Properties

    weak var delegate: ScheduleCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController

    private let viewController: ScheduleViewController


    // MARK: - Init

    init(
        navigationController: UINavigationController,
        viewController: ScheduleViewController
    ) {
        self.navigationController = navigationController
        self.viewController = viewController
    }

  
    // MARK: - Start

    func start() {
        navigationController.setViewControllers([viewController], animated: false)
    }
}
