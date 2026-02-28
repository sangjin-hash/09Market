//
//  LoginReactor.swift
//  AuthenticateImpl
//
//  Created by Sangjin Lee
//

import ReactorKit
import RxSwift
import Domain
import Core
import Shared

final class LoginReactor: Reactor {

    enum Action {
        case googleLoginCompleted(idToken: String)
        case googleLoginFailed
        case appleLoginTapped
        case appleLoginCompleted(idToken: String, nonce: String)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setLoginCompleted
        case setError(AppError?)
    }
    
    struct State {
        var isLoading: Bool = false
        var isLoginCompleted: Bool = false
        var error: AppError? = nil
    }
    
    let initialState = State()
    
    private let signInWithIdTokenUseCase: SignInWithIdTokenUseCase
    
    init(signInWithIdTokenUseCase: SignInWithIdTokenUseCase) {
        self.signInWithIdTokenUseCase = signInWithIdTokenUseCase
    }
}

extension LoginReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .googleLoginCompleted(let idToken):
            return Observable.concat([
                .just(.setLoading(true)),
                Observable.task {
                    try await self.signInWithIdTokenUseCase.execute(
                        provider: "google",
                        idToken: idToken,
                        nonce: nil
                    )
                }
                .map { _ in Mutation.setLoginCompleted }
                .catch { .just(.setError($0 as? AppError)) },
                .just(.setLoading(false))
            ])
            
        case .googleLoginFailed:
            return .just(.setError(AppError.auth(.providerFailed)))

        // TODO: - 추후 Apple Login 연동 때 작업할 것
            
        case .appleLoginTapped:
            return .empty()
            
        case .appleLoginCompleted(let idToken, let nonce):
            return Observable.concat([
                .just(.setLoading(true)),
                Observable.task {
                    try await self.signInWithIdTokenUseCase.execute(
                        provider: "apple",
                        idToken: idToken,
                        nonce: nonce
                    )
                }
                .map { _ in Mutation.setLoginCompleted }
                .catch { .just(.setError($0 as? AppError)) },
                .just(.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let value):
            newState.isLoading = value
        case .setLoginCompleted:
            newState.isLoginCompleted = true
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
