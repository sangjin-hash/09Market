//
//  SearchInfluencersUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol SearchInfluencersUseCase {
    func execute(_ username: String) async throws -> [Influencer]
}
