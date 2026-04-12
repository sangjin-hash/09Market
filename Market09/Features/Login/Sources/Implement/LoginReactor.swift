//
//  LoginReactor.swift
//  LoginImpl
//
//  Created by Sangjin Lee
//
import Foundation

import AppCore
import Domain
import Shared_DI
import Shared_ReactiveX

import CryptoKit

final class LoginReactor: Reactor, FactoryModule {
    
    struct Dependency {
        let signInWithIdTokenUseCase: SignInWithIdTokenUseCase
    }
    
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
        case setAppleLoginNonce(raw: String, hashed: String)
    }
    
    struct State {
        var isLoading: Bool = false
        var isLoginCompleted: Bool = false
        @Pulse var error: AppError?
      var appleLoginNonce: String?
      @Pulse var appleLoginHashedNonce: String?
    }
    
    let initialState: State = State()
    private let dependency: Dependency
    
    required init(dependency: Dependency, payload: Void) {
        self.dependency = dependency
    }
}

extension LoginReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .googleLoginCompleted(let idToken):
            return Observable.concat([
                .just(.setLoading(true)),
                Observable.task {
                    try await self.dependency.signInWithIdTokenUseCase.execute(
                        provider: .google,
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
            let nonce = Self.randomNonceString()
            let hashedNonce = Self.sha256(nonce)
            return .just(.setAppleLoginNonce(raw: nonce, hashed: hashedNonce))
            
        case .appleLoginCompleted(let idToken, let nonce):
            return Observable.concat([
                .just(.setLoading(true)),
                Observable.task {
                    try await self.dependency.signInWithIdTokenUseCase.execute(
                        provider: .apple,
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

        case .setAppleLoginNonce(raw: let raw, hashed: let hashed):
            newState.appleLoginNonce = raw
            newState.appleLoginHashedNonce = hashed
        }
        return newState
    }
}


// MARK: - Nonce Generation

private extension LoginReactor {
    static func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String((0..<length).map { _ in charset.randomElement()! })
    }

    static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Foundation.Data(input.utf8))
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
