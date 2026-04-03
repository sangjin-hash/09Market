//
//  ScheduleViewReactor.swift
//  ScheduleImpl
//
//  Created by 23ji
//

import Foundation

import AppCore
import Shared_DI
import Shared_ReactiveX

final class ScheduleViewReactor: Reactor, FactoryModule {

    // MARK: - Module

    struct Dependency {
    }

    struct Payload {
    }


    // MARK: - Reactor

    enum Action {
    }

    enum Mutation {
    }

    struct State {
    }


    // MARK: - Properties

    private let dependency: Dependency
    private let payload: Payload
    var disposeBag = DisposeBag()
    var initialState: State


    // MARK: - Init

    init(dependency: Dependency, payload: Payload) {
        self.dependency = dependency
        self.payload = payload
        self.initialState = State()
    }
}
