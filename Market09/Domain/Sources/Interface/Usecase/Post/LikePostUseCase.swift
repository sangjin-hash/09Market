//
//  LikePostUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol LikePostUseCase {
    func execute(postId: String) async throws
}
