//
//  LoginAssembly.swift
//  LoginImpl
//
//  Created by Sangjin Lee
//

import Core
import Domain
import Login
import Shared_DI
import UIKit

public final class LoginAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(LoginReactor.self) { r in
            LoginReactor(signInWithIdTokenUseCase: r.resolve())
        }

        container.register(LoginCoordinator.self) { (r, navigation: UINavigationController) in
            LoginCoordinatorImpl(
                navigationController: navigation,
                loginReactor: r.resolve()
            )
        }
    }
}
