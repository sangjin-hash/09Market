//
//  AuthAssembly.swift
//  AuthenticateImpl
//
//  Created by Sangjin Lee
//

import UIKit
import Swinject
import Core
import Domain
import Authenticate

public final class AuthAssembly: Assembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        container.register(LoginReactor.self) { resolver in
            LoginReactor(
                signInWithIdTokenUseCase: resolver.resolve(SignInWithIdTokenUseCase.self)!
            )
        }
        
        container.register(LaunchAuthReactor.self) { resolver in
            LaunchAuthReactor(
                checkAuthOnLaunchUseCase: resolver.resolve(CheckAuthOnLaunchUseCase.self)!
            )
        }
        
        container.register(AuthCoordinator.self) { (resolver, navigation: UINavigationController) in
            AuthCoordinatorImpl(
                navigationController: navigation,
                launchAuthReactor: resolver.resolve(LaunchAuthReactor.self)!,
                loginReactor: resolver.resolve(LoginReactor.self)!
            )
        }
    }
}
