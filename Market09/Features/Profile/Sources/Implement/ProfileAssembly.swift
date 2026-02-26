//
//  ProfileAssembly.swift
//  ProfileImpl
//
//  Created by Sangjin Lee
//

import UIKit
import Swinject
import Core
import Domain
import Profile

public final class ProfileAssembly: Assembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        container.register(ProfileReactor.self) { resolver in
            ProfileReactor(
                signOutUseCase: resolver.resolve(SignOutUseCase.self)!,
                deleteAccountUseCase: resolver.resolve(DeleteAccountUseCase.self)!
            )
        }
        
        container.register(ProfileCoordinator.self) { (resolver, navigationController: UINavigationController) in
            ProfileCoordinatorImpl(
                navigationController: navigationController,
                reactor: resolver.resolve(ProfileReactor.self)!
            )
        }
    }
}
