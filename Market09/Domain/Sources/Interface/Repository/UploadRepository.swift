//
//  UploadRepository.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Foundation

import AppCore

public protocol UploadRepository {
    /// 이미지 -> 저장소 업로드
    /// - Parameters:
    ///   - imageData: 업로드할 이미지 바이너리
    ///   - mimeType: MIME 타입 (예: "image/jpeg", "image/png")
    /// - Returns: Supabase Storage에 저장된 이미지 Public URL
    func uploadImage(_ imageData: Data, _ mimeType: String) async throws -> String
}
