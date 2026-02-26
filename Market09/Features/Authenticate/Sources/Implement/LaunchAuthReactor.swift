//
//  LaunchAuthReactor.swift
//  AuthenticateImpl
//
//  Created by Sangjin Lee
//

import ReactorKit
import RxSwift
import Domain
import Core
import Shared

final class LaunchAuthReactor: Reactor {
    
    enum Action {
        case checkAuth
    }
    
    enum Mutation {
        case setAuthState(AuthState)
    }
    
    struct State {
        var authState: AuthState? = nil
    }
    
    let initialState = State()
    
    private let checkAuthOnLaunchUseCase: CheckAuthOnLaunchUseCase

    init(checkAuthOnLaunchUseCase: CheckAuthOnLaunchUseCase) {
        self.checkAuthOnLaunchUseCase = checkAuthOnLaunchUseCase
    }
}

extension LaunchAuthReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkAuth:
            return Observable.task { try await self.checkAuthOnLaunchUseCase.execute() }
                .map { Mutation.setAuthState($0) }
                .catch { _ in .just(.setAuthState(.anonymous)) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAuthState(let authState):
            newState.authState = authState
        }
        return newState
    }
}
