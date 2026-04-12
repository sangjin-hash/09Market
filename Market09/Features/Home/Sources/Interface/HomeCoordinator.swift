//
//  HomeCoordinator.swift
//  Home
//
//  Created by Sangjin Lee
//

import AppCore

public protocol HomeCoordinator: Coordinator {
    var delegate: HomeCoordinatorDelegate? { get set }
    func showTop10()
}
