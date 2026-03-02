//
//  DomainAssembly.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Core
import Swinject

public final class DomainAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {

        // MARK: - UserStore

        container.register(UserStore.self) { _ in
            UserStore()
        }.inObjectScope(.container)

        // MARK: - Auth

        container.register(SignInWithIdTokenUseCase.self) { resolver in
            SignInWithIdTokenUseCaseImpl(
                authRepository: resolver.resolve(AuthRepository.self)!,
                userRepository: resolver.resolve(UserRepository.self)!,
                userStore: resolver.resolve(UserStore.self)!
            )
        }.inObjectScope(.container)

        container.register(SignOutUseCase.self) { resolver in
            SignOutUseCaseImpl(
                authRepository: resolver.resolve(AuthRepository.self)!,
                userStore: resolver.resolve(UserStore.self)!
            )
        }.inObjectScope(.container)

        container.register(DeleteAccountUseCase.self) { resolver in
            DeleteAccountUseCaseImpl(
                authRepository: resolver.resolve(AuthRepository.self)!,
                userStore: resolver.resolve(UserStore.self)!
            )
        }.inObjectScope(.container)

        // MARK: - User

        container.register(GetMeUseCase.self) { resolver in
            GetMeUseCaseImpl(
                userRepository: resolver.resolve(UserRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(CheckAuthOnLaunchUseCase.self) { resolver in
            CheckAuthOnLaunchUseCaseImpl(
                authRepository: resolver.resolve(AuthRepository.self)!,
                userRepository: resolver.resolve(UserRepository.self)!,
                userStore: resolver.resolve(UserStore.self)!
            )
        }.inObjectScope(.container)
    }
}
