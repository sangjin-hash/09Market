//
//  LoginCoordinator.swift
//  Login
//
//  Created by Sangjin Lee
//

import Core

public protocol LoginCoordinator: Coordinator {
    var delegate: LoginCoordinatorDelegate? { get set }
}
