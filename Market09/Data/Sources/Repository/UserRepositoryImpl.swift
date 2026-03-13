//
//  UserRepositoryImpl.swift
//  Data
//
//  Created by Sangjin Lee
//

import Core
import Domain

final class UserRepositoryImpl: UserRepository {
    private let remoteDataSource: UserRemoteDataSource

    init(remoteDataSource: UserRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchMe() async throws -> User? {
        return try await self.remoteDataSource.fetchMe()
            .map(UserMapper.toUserEntity)
    }
}
