//
//  ImageUploadServiceKey.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/27/25.
//  Task 9: Environment Key for Image Upload Service
//

import SwiftUI

// MARK: - Environment Key

private struct ImageUploadServiceKey: EnvironmentKey {
    static let defaultValue = ImageUploadService()
}

extension EnvironmentValues {
    var imageUploadService: ImageUploadService {
        get { self[ImageUploadServiceKey.self] }
        set { self[ImageUploadServiceKey.self] = newValue }
    }
}
