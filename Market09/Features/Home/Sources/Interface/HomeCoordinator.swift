//
//  HomeCoordinator.swift
//  Home
//
//  Created by Sangjin Lee
//

import Core

public protocol HomeCoordinator: Coordinator {
    var delegate: HomeCoordinatorDelegate? { get set }
}
