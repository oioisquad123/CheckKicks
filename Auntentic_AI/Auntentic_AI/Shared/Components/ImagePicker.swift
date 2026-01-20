//
//  ImagePicker.swift
//  Auntentic_AI
//

import SwiftUI
import UIKit

/// UIViewControllerRepresentable wrapper for UIImagePickerController with custom overlay support
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    let sourceType: UIImagePickerController.SourceType
    var silhouetteIcon: String? = nil

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        
        if sourceType == .camera, let icon = silhouetteIcon {
            // Create a custom overlay
            let overlay = UIView(frame: UIScreen.main.bounds)
            overlay.backgroundColor = .clear
            overlay.isUserInteractionEnabled = false // Allow taps to pass through to the camera shutter
            
            // Add a small guide icon/silhouette in the corner or center
            let guideContainer = UIView()
            guideContainer.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            guideContainer.layer.cornerRadius = 12
            guideContainer.translatesAutoresizingMaskIntoConstraints = false
            overlay.addSubview(guideContainer)
            
            let imageView = UIImageView(image: UIImage(systemName: icon))
            imageView.tintColor = .white
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            guideContainer.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                guideContainer.topAnchor.constraint(equalTo: overlay.topAnchor, constant: 100),
                guideContainer.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -20),
                guideContainer.widthAnchor.constraint(equalToConstant: 80),
                guideContainer.heightAnchor.constraint(equalToConstant: 80),
                
                imageView.centerXAnchor.constraint(equalTo: guideContainer.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: guideContainer.centerYAnchor),
                imageView.widthAnchor.constraint(equalTo: guideContainer.widthAnchor, multiplier: 0.7),
                imageView.heightAnchor.constraint(equalTo: guideContainer.heightAnchor, multiplier: 0.7)
            ])
            
            // Add a "Guide" label
            let label = UILabel()
            label.text = "GUIDE"
            label.textColor = .white
            label.font = .systemFont(ofSize: 10, weight: .bold)
            label.translatesAutoresizingMaskIntoConstraints = false
            guideContainer.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.bottomAnchor.constraint(equalTo: guideContainer.bottomAnchor, constant: -4),
                label.centerXAnchor.constraint(equalTo: guideContainer.centerXAnchor)
            ])
            
            picker.cameraOverlayView = overlay
        }
        
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
