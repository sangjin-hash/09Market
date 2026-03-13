//
//  FetchMeUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Core

public protocol FetchMeUseCase {
    func execute() async throws -> User?
}
