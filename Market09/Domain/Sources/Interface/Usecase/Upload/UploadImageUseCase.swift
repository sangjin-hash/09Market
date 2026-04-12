//
//  UploadImageUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Foundation

public protocol UploadImageUseCase {
    func execute(_ imageData: Data, _ mimeType: String) async throws -> String
}
