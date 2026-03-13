//
//  DomainAssembly.swift
//  DomainImpl
//
//  Created by Sangjin Lee
//

import Core
import Domain
import Shared_DI

public final class DomainAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {

        // MARK: - UserStore

        container.register(UserStore.self) { _ in
            UserStore()
        }.inObjectScope(.container)


        // MARK: - Auth

        container.register(CheckAuthOnLaunchUseCase.self) { r in
            CheckAuthOnLaunchUseCaseImpl(
                authRepository: r.resolve(),
                userRepository: r.resolve(),
                userStore: r.resolve()
            )
        }.inObjectScope(.container)
        
        container.register(SignInWithIdTokenUseCase.self) { r in
            SignInWithIdTokenUseCaseImpl(
                authRepository: r.resolve(),
                userRepository: r.resolve(),
                userStore: r.resolve()
            )
        }.inObjectScope(.container)

        container.register(SignOutUseCase.self) { r in
            SignOutUseCaseImpl(
                authRepository: r.resolve(),
                userStore: r.resolve()
            )
        }.inObjectScope(.container)

        container.register(DeleteAccountUseCase.self) { r in
            DeleteAccountUseCaseImpl(
                authRepository: r.resolve(),
                userStore: r.resolve()
            )
        }.inObjectScope(.container)


        // MARK: - User

        container.register(FetchMeUseCase.self) { r in
            FetchMeUseCaseImpl(userRepository: r.resolve())
        }.inObjectScope(.container)

        
        // MARK: - Post
        
        container.register(FetchPostsListUseCase.self) { r in
            FetchPostsListUseCaseImpl(postRepository: r.resolve())
        }.inObjectScope(.container)
        
        container.register(FetchTop10PostsUseCase.self) { r in
            FetchTop10PostsUseCaseImpl(postRepository: r.resolve())
        }.inObjectScope(.container)
    }
}
