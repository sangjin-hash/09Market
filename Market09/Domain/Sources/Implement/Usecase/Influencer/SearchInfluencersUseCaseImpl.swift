//
//  SearchInfluencersUseCaseImpl.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Domain

final class SearchInfluencersUseCaseImpl: SearchInfluencersUseCase {
    private let influencerRepository: InfluencerRepository

    init(influencerRepository: InfluencerRepository) {
        self.influencerRepository = influencerRepository
    }

    func execute(_ username: String) async throws -> [Influencer] {
        return try await self.influencerRepository.searchInfluencers(username)
    }
}
