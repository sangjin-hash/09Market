//
//  CreatePostUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol CreatePostUseCase {
    func execute(_ post: Post) async throws -> Post
}
