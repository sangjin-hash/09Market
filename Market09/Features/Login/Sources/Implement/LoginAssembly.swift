//
//  LoginAssembly.swift
//  LoginImpl
//
//  Created by Sangjin Lee
//

import Core
import Domain
import Login
import UIKit

import Swinject

public final class LoginAssembly: Assembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        container.register(LoginReactor.self) { resolver in
            LoginReactor(
                signInWithIdTokenUseCase: resolver.resolve(SignInWithIdTokenUseCase.self)!
            )
        }
        
        container.register(LoginCoordinator.self) { (resolver, navigation: UINavigationController) in
            LoginCoordinatorImpl(
                navigationController: navigation,
                loginReactor: resolver.resolve(LoginReactor.self)!
            )
        }
    }
}
