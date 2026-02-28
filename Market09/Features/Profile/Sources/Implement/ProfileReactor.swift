//
//  ProfileReactor.swift
//  Profile
//
//  Created by Sangjin Lee
//

import ReactorKit
import RxSwift
import Domain
import Core
import Shared

final class ProfileReactor: Reactor {
    
    enum Action {
        case viewDidAppear
        case loginButtonTapped
        case logoutButtonTapped
        case deleteAccountTapped
    }
    
    enum Mutation {
        case setUser(User?)
        case setLoading(Bool)
        case setError(AppError?)
    }

    struct State {
        var user: User?
        var isLoggedIn: Bool = false
        var isLoading: Bool = false
        var error: AppError? = nil
    }

    let initialState = State()

    private let signOutUseCase: SignOutUseCase
    private let deleteAccountUseCase: DeleteAccountUseCase
    private let userStore: UserStore

    init(
        signOutUseCase: SignOutUseCase,
        deleteAccountUseCase: DeleteAccountUseCase,
        userStore: UserStore
    ) {
        self.signOutUseCase = signOutUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
        self.userStore = userStore
    }
}

extension ProfileReactor {
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let userMutation = userStore.currentUser
            .map { Mutation.setUser($0) }
            .asObservable()
        return .merge(mutation, userMutation)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidAppear:
            return .empty()

        case .loginButtonTapped:
            return .empty()

        case .logoutButtonTapped:
            return Observable.concat([
                .just(.setLoading(true)),
                Observable.task { try await self.signOutUseCase.execute() }
                    .map { _ in Mutation.setUser(nil) }
                    .catch { .just(.setError($0 as? AppError)) },
                .just(.setLoading(false))
            ])

        case .deleteAccountTapped:
            return Observable.concat([
                .just(.setLoading(true)),
                Observable.task { try await self.deleteAccountUseCase.execute() }
                    .map { _ in Mutation.setUser(nil) }
                    .catch { .just(.setError($0 as? AppError)) },
                .just(.setLoading(false))
            ])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setUser(let user):
            newState.user = user
            newState.isLoggedIn = user != nil
        case .setLoading(let value):
            newState.isLoading = value
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
