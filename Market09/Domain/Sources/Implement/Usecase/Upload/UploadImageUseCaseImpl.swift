//
//  UploadImageUseCaseImpl.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Foundation

import Domain

final class UploadImageUseCaseImpl: UploadImageUseCase {
    private let uploadRepository: UploadRepository
    
    init(uploadRepository: UploadRepository) {
        self.uploadRepository = uploadRepository
    }
    
    func execute(_ imageData: Data, _ mimeType: String) async throws -> String {
        return try await self.uploadRepository.uploadImage(imageData, mimeType)
    }
}
