//
//  DomainAssembly.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Swinject

public final class DomainAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        
        // MARK: - Auth
        
        container.register(SignInAnonymouslyUseCase.self) { resolver in
            SignInAnonymouslyUseCaseImpl(
                authRepository: resolver.resolve(AuthRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(SignInWithIdTokenUseCase.self) { resolver in
            SignInWithIdTokenUseCaseImpl(
                authRepository: resolver.resolve(AuthRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(RefreshTokenUseCase.self) { resolver in
            RefreshTokenUseCaseImpl(
                authRepository: resolver.resolve(AuthRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(SignOutUseCase.self) { resolver in
            SignOutUseCaseImpl(
                authRepository: resolver.resolve(AuthRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(DeleteAccountUseCase.self) { resolver in
            DeleteAccountUseCaseImpl(
                authRepository: resolver.resolve(AuthRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(CheckAuthOnLaunchUseCase.self) { resolver in
            CheckAuthOnLaunchUseCaseImpl(
                authRepository: resolver.resolve(AuthRepository.self)!
            )
        }.inObjectScope(.container)
    }
}
