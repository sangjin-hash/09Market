//
//  AuthCoordinator.swift
//  Authenticate
//
//  Created by Sangjin Lee
//

import Core

public protocol AuthCoordinator: Coordinator {
    var delegate: AuthCoordinatorDelegate? { get set }
    
    func showLogin()
}
