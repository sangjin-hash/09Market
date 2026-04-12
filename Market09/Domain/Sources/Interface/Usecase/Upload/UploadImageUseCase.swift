//
//  UploadImageUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Foundation

public protocol UploadImageUseCase {
    func execute(_ imageData: Data, _ mimeType: MimeType) async throws -> String
}
