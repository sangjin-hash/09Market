//
//  ProfileCoordinator.swift
//  Profile
//
//  Created by Sangjin Lee
//

import Core

public protocol ProfileCoordinator: Coordinator {
    var delegate: ProfileCoordinatorDelegate? { get set }
}
