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
        case setLoggedIn(Bool)
        case setLoading(Bool)
        case setError(AppError?)
    }
    
    struct State {
        var isLoggedIn: Bool = false
        var isLoading: Bool = false
        var error: AppError? = nil
    }
    
    let initialState = State()

    private let signOutUseCase: SignOutUseCase
    private let deleteAccountUseCase: DeleteAccountUseCase
    
    init(
        signOutUseCase: SignOutUseCase,
        deleteAccountUseCase: DeleteAccountUseCase
    ){
        self.signOutUseCase = signOutUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
    }
}

extension ProfileReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidAppear:
            // TODO: 소셜 로그인 여부 확인 로직
            return .empty()

        case .loginButtonTapped:
            // TODO: 소셜 로그인
            return .empty()

        case .logoutButtonTapped:
            return Observable.concat([
                .just(.setLoading(true)),
                Observable.task { try await self.signOutUseCase.execute() }
                    .map { _ in Mutation.setLoggedIn(false) }
                    .catch { .just(.setError($0 as? AppError)) },
                .just(.setLoading(false))
            ])

        case .deleteAccountTapped:
            return Observable.concat([
                .just(.setLoading(true)),
                Observable.task { try await self.deleteAccountUseCase.execute() }
                    .map { _ in Mutation.setLoggedIn(false) }
                    .catch { .just(.setError($0 as? AppError)) },
                .just(.setLoading(false))
            ])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoggedIn(let value):
            newState.isLoggedIn = value
        case .setLoading(let value):
            newState.isLoading = value
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
