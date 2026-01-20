//
//  ImageCompressor.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/27/25.
//  Task 8: Image compression utility
//

import UIKit
import OSLog

/// Utility for compressing images to target file size
struct ImageCompressor {
    private static let logger = Logger(subsystem: "com.checkkicks.app", category: "ImageCompressor")

    /// Target file size in bytes (200KB - optimized for upload)
    static let targetSizeBytes: Int = 204_800 // ~200KB (reduced from 500KB to handle upload limits)

    /// Maximum dimension for resized images (width or height)
    static let maxDimension: CGFloat = 1920 // 1080p quality

    /// Compress image to target size (default 200KB)
    /// - Parameters:
    ///   - image: The UIImage to compress
    ///   - targetSizeBytes: Maximum file size in bytes
    /// - Returns: Compressed JPEG data, or nil if compression failed
    static func compress(_ image: UIImage, targetSizeBytes: Int = targetSizeBytes) -> Data? {
        logger.info("📦 Starting compression for image size: \(image.size.width)x\(image.size.height)")

        // Step 1: Resize image if dimensions are too large
        let resizedImage = resizeImage(image, maxDimension: maxDimension)
        logger.info("📐 Resized to: \(resizedImage.size.width)x\(resizedImage.size.height)")

        // Step 2: Start with high quality compression
        var compression: CGFloat = 0.8
        guard var imageData = resizedImage.jpegData(compressionQuality: compression) else {
            logger.error("❌ Failed to get JPEG data from image")
            return nil
        }

        logger.info("🔍 Initial size: \(imageData.count) bytes (target: \(targetSizeBytes) bytes)")

        // If already under target, return it
        if imageData.count <= targetSizeBytes {
            logger.info("✅ Image already under target size at quality \(compression)")
            return imageData
        }

        // Binary search for optimal compression quality
        var maxQuality: CGFloat = 1.0
        var minQuality: CGFloat = 0.0

        // Try up to 10 iterations to find optimal compression
        for iteration in 1...10 {
            compression = (maxQuality + minQuality) / 2

            guard let data = image.jpegData(compressionQuality: compression) else {
                logger.error("❌ Failed to compress at quality \(compression)")
                break
            }

            imageData = data
            let sizeKB = Double(imageData.count) / 1024.0

            logger.info("🔄 Iteration \(iteration): Quality \(String(format: "%.2f", compression)) → \(String(format: "%.1f", sizeKB))KB")

            if imageData.count > targetSizeBytes {
                // Still too large, reduce quality
                maxQuality = compression
            } else if imageData.count < targetSizeBytes * 9 / 10 {
                // Too small, could increase quality
                minQuality = compression
            } else {
                // Within acceptable range (90-100% of target)
                logger.info("✅ Found optimal compression: \(String(format: "%.2f", compression)) → \(String(format: "%.1f", sizeKB))KB")
                break
            }
        }

        let finalSizeKB = Double(imageData.count) / 1024.0
        logger.info("✅ Final compressed size: \(String(format: "%.1f", finalSizeKB))KB at quality \(String(format: "%.2f", compression))")

        return imageData
    }

    /// Compress image and return as UIImage
    /// - Parameters:
    ///   - image: The UIImage to compress
    ///   - targetSizeBytes: Maximum file size in bytes
    /// - Returns: Compressed UIImage, or nil if compression failed
    static func compressToImage(_ image: UIImage, targetSizeBytes: Int = targetSizeBytes) -> UIImage? {
        guard let compressedData = compress(image, targetSizeBytes: targetSizeBytes),
              let compressedImage = UIImage(data: compressedData) else {
            logger.error("❌ Failed to create compressed image")
            return nil
        }

        return compressedImage
    }

    /// Get estimated file size of an image
    /// - Parameter image: The image to measure
    /// - Returns: Estimated file size in bytes
    static func estimateFileSize(of image: UIImage) -> Int {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return 0
        }
        return data.count
    }

    /// Format bytes to human-readable string
    /// - Parameter bytes: Number of bytes
    /// - Returns: Formatted string (e.g., "1.5 MB", "500 KB")
    static func formatBytes(_ bytes: Int) -> String {
        let kb = Double(bytes) / 1024.0
        let mb = kb / 1024.0

        if mb >= 1.0 {
            return String(format: "%.1f MB", mb)
        } else {
            return String(format: "%.0f KB", kb)
        }
    }

    /// Resize image to fit within max dimension while maintaining aspect ratio
    /// - Parameters:
    ///   - image: The image to resize
    ///   - maxDimension: Maximum width or height
    /// - Returns: Resized image
    private static func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size

        // If image is already smaller than max, return original
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }

        // Calculate new size maintaining aspect ratio
        let ratio = size.width / size.height
        let newSize: CGSize

        if size.width > size.height {
            // Landscape or square
            newSize = CGSize(width: maxDimension, height: maxDimension / ratio)
        } else {
            // Portrait
            newSize = CGSize(width: maxDimension * ratio, height: maxDimension)
        }

        // Resize using UIGraphicsImageRenderer for better quality
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        logger.info("🔄 Resized from \(size.width)x\(size.height) to \(newSize.width)x\(newSize.height)")
        return resizedImage
    }
}
