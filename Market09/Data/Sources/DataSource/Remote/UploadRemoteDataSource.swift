//
//  UploadRemoteDataSource.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import AppCore

protocol UploadRemoteDataSource {
    /// POST — 이미지 업로드 (multipart/form-data)
    /// - Parameters:
    ///   - imageData: 업로드할 이미지 바이너리
    ///   - mimeType: MIME 타입 (예: "image/jpeg", "image/png")
    /// - Returns: Supabase Storage에 저장된 이미지 Public URL
    func uploadImage(_ imageData: Data, _ mimeType: String) async throws -> String
}

final class UploadRemoteDataSourceImpl: UploadRemoteDataSource, RemoteDataSource {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func uploadImage(_ imageData: Data, _ mimeType: String) async throws -> String {
        return try await performRequest {
            let endpoint = self.uploadEndpoint()
            let data = try await self.apiClient.upload(endpoint, imageData: imageData, mimeType: mimeType)
            let response = try JSONDecoder().decode(UploadResponse.self, from: data)
            return response.url
        }
    }
}

private extension UploadRemoteDataSourceImpl {
    func uploadEndpoint() -> String {
        guard let endpoint = Bundle.main.infoDictionary?["API_UPLOAD"] as? String else {
            fatalError("API_UPLOAD가 Info.plist에 없습니다. Secrets.xcconfig을 확인하세요.")
        }
        return endpoint
    }

}
