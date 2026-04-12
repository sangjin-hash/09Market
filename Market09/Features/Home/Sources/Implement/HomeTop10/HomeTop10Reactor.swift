//
//  HomeTop10Reactor.swift
//  Home
//
//  Created by Sangjin Lee
//

import Foundation

import AppCore
import Domain
import Shared_DI
import Shared_ReactiveX

final class HomeTop10Reactor: Reactor, FactoryModule {
    
    struct Dependency {
        let fetchTop10PostsUseCase: FetchTop10PostsUseCase
    }
    
    enum Action {
        case fetchTop10Posts
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setFetchCompleted([Post])
        case setError(AppError?)
    }
    
    struct State {
        var posts: [Post] = []
        var isLoading: Bool = false
        @Pulse var error: AppError?
    }
    
    let initialState: State = State()
    private let dependency: Dependency
    
    required init(dependency: Dependency, payload: Void) {
        self.dependency = dependency
    }
}


// MARK: - Mutate & Reduce

extension HomeTop10Reactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchTop10Posts:
            return .concat([
                .just(.setLoading(true)),
                Observable.task {
                    try await self.dependency.fetchTop10PostsUseCase.execute()
                }
                .map { Mutation.setFetchCompleted($0) }
                .catch { .just(Mutation.setError($0 as? AppError)) },
                .just(.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setFetchCompleted(let posts):
            newState.posts = posts
            
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
