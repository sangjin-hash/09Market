//
//  Coordinator.swift
//  Core
//
//  Created by Sangjin Lee
//

import UIKit

public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    func start()
}

public extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        self.childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        self.childCoordinators.removeAll { $0 === coordinator }
    }
}
