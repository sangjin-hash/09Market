//
//  CancelLikePostUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol CancelLikePostUseCase {
    func execute(postId: String) async throws
}
