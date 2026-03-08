//
//  UserRepositoryImpl.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import Core
import Domain

final class UserRepositoryImpl: UserRepository {
    private let remoteDataSource: UserRemoteDataSource

    init(remoteDataSource: UserRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func getMe() async throws -> User? {
        return try await self.remoteDataSource.getMe()
            .map(UserMapper.toUserEntity)
    }
}
