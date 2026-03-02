//
//  AuthAssembly.swift
//  AuthenticateImpl
//
//  Created by Sangjin Lee
//

import Authenticate
import Core
import Domain
import UIKit

import Swinject

public final class AuthAssembly: Assembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        container.register(AuthReactor.self) { resolver in
            AuthReactor(
                checkAuthOnLaunchUseCase: resolver.resolve(CheckAuthOnLaunchUseCase.self)!
            )
        }
        
        container.register(AuthCoordinator.self) { (resolver, navigation: UINavigationController) in
            AuthCoordinatorImpl(
                navigationController: navigation,
                authReactor: resolver.resolve(AuthReactor.self)!
            )
        }
    }
}
