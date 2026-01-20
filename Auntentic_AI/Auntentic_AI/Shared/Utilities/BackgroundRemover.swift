//
//  BackgroundRemover.swift
//  Auntentic_AI
//
//  Vision framework utility for removing backgrounds from shoe images
//  Created: January 6, 2026
//

import UIKit
import Vision
import CoreImage
import OSLog

@MainActor
class BackgroundRemover {
    static let shared = BackgroundRemover()
    private let context = CIContext()
    private let logger = Logger(subsystem: "com.checkkicks.app", category: "BackgroundRemover")

    // Cache for processed images to avoid re-processing
    private var imageCache: [String: UIImage] = [:]

    private init() {}

    // MARK: - Background Removal

    /// Removes background from image and places subject on white background
    func removeBackground(from image: UIImage, cacheKey: String? = nil) async -> UIImage? {
        // Check cache first
        if let key = cacheKey, let cached = imageCache[key] {
            return cached
        }

        guard let cgImage = image.cgImage else { return nil }

        // Use VNGenerateForegroundInstanceMaskRequest for iOS 17+
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])

            guard let result = request.results?.first else { return nil }

            // Generate the mask as CVPixelBuffer
            let mask = try result.generateScaledMaskForImage(
                forInstances: result.allInstances,
                from: handler
            )

            // Convert to CIImage for processing
            let maskCIImage = CIImage(cvPixelBuffer: mask)
            let originalCIImage = CIImage(cgImage: cgImage)

            // Create white background
            let whiteBackground = CIImage(color: .white)
                .cropped(to: originalCIImage.extent)

            // Scale mask to match original image size
            let scaleX = originalCIImage.extent.width / maskCIImage.extent.width
            let scaleY = originalCIImage.extent.height / maskCIImage.extent.height
            let scaledMask = maskCIImage.transformed(
                by: CGAffineTransform(scaleX: scaleX, y: scaleY)
            )

            // Blend using the mask
            guard let blendFilter = CIFilter(name: "CIBlendWithMask") else { return nil }
            blendFilter.setValue(originalCIImage, forKey: kCIInputImageKey)
            blendFilter.setValue(whiteBackground, forKey: kCIInputBackgroundImageKey)
            blendFilter.setValue(scaledMask, forKey: kCIInputMaskImageKey)

            guard let outputCIImage = blendFilter.outputImage,
                  let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                return nil
            }

            let resultImage = UIImage(cgImage: outputCGImage)

            // Cache the result
            if let key = cacheKey {
                imageCache[key] = resultImage
            }

            return resultImage

        } catch {
            logger.error("Background removal failed: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Silhouette Creation

    /// Creates a ghosted silhouette version of an image (white semi-transparent)
    func createSilhouette(from image: UIImage, opacity: Double = 0.4, cacheKey: String? = nil) async -> UIImage? {
        let silhouetteCacheKey = cacheKey.map { "\($0)_silhouette_\(opacity)" }

        // Check cache first
        if let key = silhouetteCacheKey, let cached = imageCache[key] {
            return cached
        }

        // First remove background
        guard let backgroundRemoved = await removeBackground(from: image, cacheKey: cacheKey),
              let cgImage = backgroundRemoved.cgImage else {
            return nil
        }

        let ciImage = CIImage(cgImage: cgImage)

        // Apply white color overlay with transparency
        // This creates a "ghosted" effect - convert to white while preserving shape
        guard let colorMatrixFilter = CIFilter(name: "CIColorMatrix") else { return nil }
        colorMatrixFilter.setValue(ciImage, forKey: kCIInputImageKey)

        // Set RGB to white (1.0) while adjusting alpha
        colorMatrixFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputRVector")
        colorMatrixFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        colorMatrixFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        colorMatrixFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: CGFloat(opacity)), forKey: "inputAVector")
        colorMatrixFilter.setValue(CIVector(x: 1, y: 1, z: 1, w: 0), forKey: "inputBiasVector")

        guard let outputCIImage = colorMatrixFilter.outputImage,
              let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }

        let resultImage = UIImage(cgImage: outputCGImage)

        // Cache the result
        if let key = silhouetteCacheKey {
            imageCache[key] = resultImage
        }

        return resultImage
    }

    // MARK: - Cache Management

    /// Clears the image cache
    func clearCache() {
        imageCache.removeAll()
    }

    /// Preloads and caches processed images for all photo capture steps
    func preloadImages(for steps: [PhotoCaptureStep]) async {
        for step in steps {
            guard let image = UIImage(named: step.referenceImageName) else { continue }

            // Preload background-removed version
            _ = await removeBackground(from: image, cacheKey: step.referenceImageName)

            // Preload silhouette version
            _ = await createSilhouette(from: image, opacity: 0.4, cacheKey: step.referenceImageName)
        }
    }
}
