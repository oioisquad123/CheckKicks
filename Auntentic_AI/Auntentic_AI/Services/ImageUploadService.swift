//
//  ImageUploadService.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/27/25.
//  Task 9: Image upload service to Supabase Storage
//

import Foundation
import UIKit
import Supabase
import OSLog

/// Service for uploading images to Supabase Storage
@Observable
final class ImageUploadService {

    // MARK: - Properties

    /// Upload progress (0.0 to 1.0)
    var uploadProgress: Double = 0.0

    /// Current upload status
    var uploadStatus: UploadStatus = .idle

    /// Uploaded image URLs
    var uploadedImageURLs: [URL] = []

    /// Last error
    var lastError: Error?

    private let logger = Logger(subsystem: "com.checkkicks.app", category: "ImageUpload")
    private let supabase = SupabaseClientManager.shared

    // MARK: - Upload Status

    enum UploadStatus: Equatable {
        case idle
        case compressing
        case uploading(current: Int, total: Int)
        case generatingURLs
        case completed
        case failed(Error)

        static func == (lhs: UploadStatus, rhs: UploadStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                 (.compressing, .compressing),
                 (.generatingURLs, .generatingURLs),
                 (.completed, .completed):
                return true
            case let (.uploading(l1, l2), .uploading(r1, r2)):
                return l1 == r1 && l2 == r2
            case (.failed, .failed):
                return true
            default:
                return false
            }
        }

        var description: String {
            switch self {
            case .idle:
                return "Ready to upload"
            case .compressing:
                return "Compressing images..."
            case .uploading(let current, let total):
                return "Uploading image \(current) of \(total)..."
            case .generatingURLs:
                return "Generating URLs..."
            case .completed:
                return "Upload complete!"
            case .failed(let error):
                return "Upload failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Upload Methods

    /// Upload images to Supabase Storage
    /// - Parameter images: Array of UIImages to upload (must be 6 images)
    /// - Returns: Array of signed URLs for the uploaded images
    @MainActor
    func uploadImages(_ images: [UIImage]) async throws -> [URL] {
        guard images.count == 6 else {
            throw UploadError.invalidImageCount(images.count)
        }

        // Check network connectivity before starting
        guard NetworkMonitor.shared.isConnected else {
            logger.error("❌ No internet connection")
            throw AppError.noInternet
        }

        // Log network type for debugging cellular issues
        if NetworkMonitor.shared.isExpensive {
            logger.info("📶 Uploading on cellular data - using patient retry strategy")
        }

        logger.info("🚀 Starting upload of \(images.count) images")
        uploadProgress = 0.0
        uploadedImageURLs = []
        lastError = nil

        // Get current user ID
        guard let userId = try? await supabase.auth.session.user.id.uuidString else {
            logger.error("❌ No authenticated user")
            throw UploadError.noAuthenticatedUser
        }

        // Generate unique check ID
        let checkId = UUID().uuidString
        logger.info("📋 Check ID: \(checkId)")
        logger.info("👤 User ID: \(userId)")

        // Compress images
        uploadStatus = .compressing
        logger.info("📦 Compressing images...")

        var compressedData: [Data] = []
        for (index, image) in images.enumerated() {
            guard let data = ImageCompressor.compress(image) else {
                logger.error("❌ Failed to compress image \(index + 1)")
                throw UploadError.compressionFailed(index + 1)
            }
            compressedData.append(data)
            logger.info("✅ Compressed image \(index + 1): \(ImageCompressor.formatBytes(data.count))")
        }

        // Upload each image
        var uploadedPaths: [String] = []

        for (index, data) in compressedData.enumerated() {
            let imageNumber = index + 1
            uploadStatus = .uploading(current: imageNumber, total: 6)

            // Check network before each image (catches drops during multi-image upload)
            guard NetworkMonitor.shared.isConnected else {
                logger.error("❌ Lost connection during upload (image \(imageNumber))")
                throw AppError.noInternet
            }

            // Create path: {userId}/check_{checkId}/img_{1-6}.jpg
            // Note: First folder MUST be userId to match RLS policy
            let path = "\(userId)/check_\(checkId)/img_\(imageNumber).jpg"

            // Upload progress (no PII in production logs)
            logger.info("⬆️ Uploading image \(imageNumber)/6...")
            #if DEBUG
            // Debug-only detailed logging (never in production builds)
            logger.debug("🔍 DEBUG - Path: \(path)")
            #endif

            do {
                // Upload with retry logic for network resilience
                // Using .default config (3 retries, 1-30s delays) for better cellular support
                try await RetryableRequest.execute(
                    configuration: .default,
                    shouldRetry: RetryableRequest.isRetryable
                ) {
                    try await self.supabase.storage
                        .from("sneaker-images")
                        .upload(
                            path: path,
                            file: data,
                            options: FileOptions(
                                cacheControl: "3600",
                                contentType: "image/jpeg",
                                upsert: false
                            )
                        )
                }

                uploadedPaths.append(path)
                logger.info("✅ Uploaded image \(imageNumber)")

                // Update progress
                uploadProgress = Double(imageNumber) / 6.0

            } catch {
                logger.error("❌ Upload failed for image \(imageNumber): \(error.localizedDescription)")

                uploadStatus = .failed(error)
                throw UploadError.uploadFailed(imageNumber, error)
            }
        }

        // Generate signed URLs (works with private bucket, expires in 1 hour)
        uploadStatus = .generatingURLs
        logger.info("🔗 Generating signed URLs...")

        var signedURLs: [URL] = []

        for (index, path) in uploadedPaths.enumerated() {
            do {
                let signedURL = try await supabase.storage
                    .from("sneaker-images")
                    .createSignedURL(path: path, expiresIn: 3600)  // 1 hour expiry

                signedURLs.append(signedURL)
                logger.info("✅ Generated signed URL for image \(index + 1)")

            } catch {
                logger.error("❌ Failed to generate signed URL for image \(index + 1): \(error.localizedDescription)")
                throw UploadError.urlGenerationFailed(index + 1, error)
            }
        }

        // Complete
        uploadStatus = .completed
        uploadProgress = 1.0
        uploadedImageURLs = signedURLs

        logger.info("🎉 Upload complete! \(signedURLs.count) images uploaded with signed URLs")
        logger.info("📊 Check ID for reference: \(checkId)")

        return signedURLs
    }

    /// Reset upload state
    @MainActor
    func reset() {
        uploadProgress = 0.0
        uploadStatus = .idle
        uploadedImageURLs = []
        lastError = nil
        logger.info("🔄 Upload service reset")
    }
}

// MARK: - Upload Errors

enum UploadError: LocalizedError {
    case invalidImageCount(Int)
    case noAuthenticatedUser
    case compressionFailed(Int)
    case uploadFailed(Int, Error)
    case urlGenerationFailed(Int, Error)

    var errorDescription: String? {
        switch self {
        case .invalidImageCount(let count):
            return "Expected 6 images, got \(count)"
        case .noAuthenticatedUser:
            return "No authenticated user found. Please sign in."
        case .compressionFailed(let index):
            return "Failed to compress image \(index)"
        case .uploadFailed(let index, let error):
            return "Failed to upload image \(index): \(error.localizedDescription)"
        case .urlGenerationFailed(let index, let error):
            return "Failed to generate URL for image \(index): \(error.localizedDescription)"
        }
    }
}
