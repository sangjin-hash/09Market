//
//  UploadRepositoryImpl.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import Domain

final class UploadRepositoryImpl: UploadRepository {
    private let remoteDataSource: UploadRemoteDataSource

    init(remoteDataSource: UploadRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func uploadImage(_ imageData: Data, _ mimeType: String) async throws -> String {
        return try await self.remoteDataSource.uploadImage(imageData, mimeType)
    }
}
