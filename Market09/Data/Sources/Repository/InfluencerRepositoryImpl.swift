//
//  InfluencerRepositoryImpl.swift
//  Data
//
//  Created by Sangjin Lee
//

import Domain

final class InfluencerRepositoryImpl: InfluencerRepository {
    private let remoteDataSource: InfluencerRemoteDataSource

    init(remoteDataSource: InfluencerRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func registerInfluencer(_ username: String) async throws {
        try await self.remoteDataSource.registerInfluencer(username)
    }

    func searchInfluencers(_ username: String) async throws -> [Influencer] {
        let responses = try await self.remoteDataSource.searchInfluencers(username)
        return responses.map { InfluencerMapper.toInfluencerEntity($0) }
    }
}
