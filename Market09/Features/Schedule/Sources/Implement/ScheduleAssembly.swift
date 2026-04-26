//
//  ScheduleAssembly.swift
//  ScheduleImpl
//

import AppCore
import Schedule
import Shared_DI
import UIKit

public final class ScheduleAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(ScheduleReactor.Factory.self) { r in
            ScheduleReactor.Factory(dependency: .init())
        }
        .inObjectScope(.graph)
        
        container.register(ScheduleViewController.Factory.self) { r in
            ScheduleViewController.Factory(dependency: .init(
                reactor: r.resolve(ScheduleReactor.Factory.self)!.create()
            ))
        }
        .inObjectScope(.graph)

        container.register(ScheduleCoordinator.self) { (r, navigation: UINavigationController) in
            ScheduleCoordinatorImpl(
                navigationController: navigation,
                viewController: r.resolve(ScheduleViewController.Factory.self)!.create()
            )
        }
        .inObjectScope(.graph)
    }
}
