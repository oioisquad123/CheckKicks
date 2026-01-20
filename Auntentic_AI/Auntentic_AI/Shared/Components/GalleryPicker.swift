//
//  GalleryPicker.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/27/25.
//  Task 8: Gallery picker using PHPickerViewController
//

import SwiftUI
import PhotosUI
import OSLog

/// SwiftUI wrapper for PHPickerViewController to select photos from gallery
struct GalleryPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    private let logger = Logger(subsystem: "com.checkkicks.app", category: "GalleryPicker")

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: GalleryPicker
        private let logger = Logger(subsystem: "com.checkkicks.app", category: "GalleryPicker.Coordinator")

        init(_ parent: GalleryPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            logger.info("📸 Gallery picker finished with \(results.count) selections")

            guard let result = results.first else {
                logger.info("ℹ️ No image selected")
                // Dismiss picker when no selection
                picker.dismiss(animated: true)
                return
            }

            // Load the image BEFORE dismissing picker
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard let self = self else { return }

                    if let error = error {
                        self.logger.error("❌ Failed to load image: \(error.localizedDescription)")
                        // Dismiss picker on error
                        DispatchQueue.main.async {
                            picker.dismiss(animated: true)
                        }
                        return
                    }

                    guard let image = image as? UIImage else {
                        self.logger.error("❌ Failed to cast to UIImage")
                        // Dismiss picker on error
                        DispatchQueue.main.async {
                            picker.dismiss(animated: true)
                        }
                        return
                    }

                    self.logger.info("✅ Image loaded: \(image.size.width)x\(image.size.height)")

                    // Update binding and dismiss picker on main thread AFTER image loads
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image
                        self.logger.info("🎯 Image assigned to binding, dismissing picker")
                        picker.dismiss(animated: true)
                    }
                }
            } else {
                logger.error("❌ Cannot load image from result")
                // Dismiss picker on error
                picker.dismiss(animated: true)
            }
        }
    }
}
