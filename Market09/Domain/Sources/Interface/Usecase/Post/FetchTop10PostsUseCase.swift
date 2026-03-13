//
//  FetchTop10PostsUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol FetchTop10PostsUseCase {
    func execute() async throws -> [Post]
}
