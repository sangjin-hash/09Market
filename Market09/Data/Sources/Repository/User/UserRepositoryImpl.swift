//
//  UserRepositoryImpl.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation
import Domain

final class UserRepositoryImpl: UserRepository {

    private let remoteDataSource: UserRemoteDataSource

    init(remoteDataSource: UserRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func getMe() async throws -> User? {
        try await remoteDataSource.getMe()
            .map(UserMapper.toUserEntity)
    }
}
