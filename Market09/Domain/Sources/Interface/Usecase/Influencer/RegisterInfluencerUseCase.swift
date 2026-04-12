//
//  RegisterInfluencerUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol RegisterInfluencerUseCase {
    func execute(_ username: String) async throws
}
