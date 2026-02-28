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
        case setError(AppError)
    }

    struct State {
        var authState: AuthState? = nil
        var error: AppError? = nil
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
                .catch { error in
                    let appError = (error as? AppError) ?? .unknown(message: error.localizedDescription)
                    return .just(.setError(appError))
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAuthState(let authState):
            newState.authState = authState
            newState.error = nil
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
