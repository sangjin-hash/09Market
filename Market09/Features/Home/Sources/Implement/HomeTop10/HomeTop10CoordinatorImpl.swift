//
//  HomeTop10CoordinatorImpl.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore


// MARK: - Protocol

protocol HomeTop10Coordinator: Coordinator {}


// MARK: - Coordinator

final class HomeTop10CoordinatorImpl: HomeTop10Coordinator {

    // MARK: - Coordinator Protocol

    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController


    // MARK: - Properties

    private let viewController: HomeTop10ViewController


    // MARK: - Init

    init(navigationController: UINavigationController, viewController: HomeTop10ViewController) {
        self.navigationController = navigationController
        self.viewController = viewController
    }


    // MARK: - Start

    func start() {
        self.navigationController.pushViewController(self.viewController, animated: true)
    }
}
