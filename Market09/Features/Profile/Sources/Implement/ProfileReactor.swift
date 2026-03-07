//
//  ProfileReactor.swift
//  Profile
//
//  Created by Sangjin Lee
//

import Core
import Domain
import Shared_ReactiveX

final class ProfileReactor: Reactor {
    
    enum Action {
        case viewDidAppear
        case loginButtonTapped
        case loginRequired
        case logoutButtonTapped
        case deleteAccountTapped
    }

    enum Mutation {
        case setUser(User?)
        case setLoginRequested
        case setLoginRequired
        case setLoading(Bool)
        case setError(AppError?)
    }

    struct State {
        var user: User?
        var isLoggedIn: Bool = false
        var isLoading: Bool = false
        @Pulse var loginRequested: Void?
        @Pulse var loginRequired: Void?
        @Pulse var error: AppError?
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
            return .just(.setLoginRequested)

        case .loginRequired:
            return .just(.setLoginRequired)

        case .logoutButtonTapped:
            guard let provider = userStore.currentUser.value?.provider else {
                return .just(.setError(AppError.auth(.providerFailed)))
            }
            return Observable.concat([
                .just(.setLoading(true)),
                Observable.task { try await self.signOutUseCase.execute(provider: provider) }
                    .map { _ in Mutation.setUser(nil) }
                    .catch { .just(.setError($0 as? AppError)) },
                .just(.setLoading(false))
            ])

        case .deleteAccountTapped:
            return .empty()
            
            // TODO: 추후 계정 삭제 API 완성 시 해당 주석 해제
//            return Observable.concat([
//                .just(.setLoading(true)),
//                Observable.task { try await self.deleteAccountUseCase.execute() }
//                    .map { _ in Mutation.setUser(nil) }
//                    .catch { .just(.setError($0 as? AppError)) },
//                .just(.setLoading(false))
//            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setUser(let user):
            newState.user = user
            newState.isLoggedIn = user != nil
            
        case .setLoginRequested:
            newState.loginRequested = Void()

        case .setLoginRequired:
            newState.loginRequired = Void()

        case .setLoading(let value):
            newState.isLoading = value
            
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
