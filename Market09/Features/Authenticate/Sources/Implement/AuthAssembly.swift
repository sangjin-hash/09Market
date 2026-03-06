//
//  AuthAssembly.swift
//  AuthenticateImpl
//
//  Created by Sangjin Lee
//

import Authenticate
import Core
import Domain
import Shared_DI
import UIKit

public final class AuthAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(AuthReactor.self) { r in
            AuthReactor(checkAuthOnLaunchUseCase: r.resolve())
        }

        container.register(AuthCoordinator.self) { (r, navigation: UINavigationController) in
            AuthCoordinatorImpl(
                navigationController: navigation,
                authReactor: r.resolve()
            )
        }
    }
}
