//
//  ScheduleCoordinatorImpl.swift
//  ScheduleImpl
//
//  Created by 23ji
//

import UIKit

import AppCore
import Schedule
import Shared_DI

final class ScheduleCoordinatorImpl: ScheduleCoordinator {

    // MARK: - Coordinator Protocol

    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController


    // MARK: - Delegate

    public weak var delegate: ScheduleCoordinatorDelegate?


    // MARK: - Reactor

    //private let viewController: ScheduleViewController


    // MARK: - Init

    public init(
        navigationController: UINavigationController,
    ) {
        self.navigationController = navigationController
    }


    // MARK: - Start

    public func start() {
//        guard let reactor = self.viewController.reactor else { return }
//        
//        reactor.pulse(\.$loginConfirmed)
//            .filter { $0 }
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] _ in
//                self?.delegate?.homeDidRequestLogin()
//            })
//            .disposed(by: self.disposeBag)
//        
//        self.navigationController.pushViewController(self.viewController, animated: true)
    }
}
