//
//  GetMeUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Core

public protocol GetMeUseCase {
    func execute() async throws -> User?
}
