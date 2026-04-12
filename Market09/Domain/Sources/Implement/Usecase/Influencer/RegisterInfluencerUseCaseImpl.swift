//
//  RegisterInfluencerUseCaseImpl.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Domain

final class RegisterInfluencerUseCaseImpl: RegisterInfluencerUseCase {
    private let influencerRepository: InfluencerRepository
    
    init(influencerRepository: InfluencerRepository) {
        self.influencerRepository = influencerRepository
    }
    
    func execute(_ username: String) async throws {
        try await self.influencerRepository.registerInfluencer(username)
    }
}
