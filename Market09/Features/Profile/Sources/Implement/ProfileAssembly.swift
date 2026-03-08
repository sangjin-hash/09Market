//
//  ProfileAssembly.swift
//  ProfileImpl
//
//  Created by Sangjin Lee
//

import UIKit

import Core
import Domain
import Profile
import Shared_DI

public final class ProfileAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(ProfileReactor.self) { r in
            ProfileReactor(
                signOutUseCase: r.resolve(),
                deleteAccountUseCase: r.resolve(),
                userStore: r.resolve()
            )
        }

        container.register(ProfileCoordinator.self) { (r, navigationController: UINavigationController) in
            ProfileCoordinatorImpl(
                navigationController: navigationController,
                reactor: r.resolve()
            )
        }
    }
}
