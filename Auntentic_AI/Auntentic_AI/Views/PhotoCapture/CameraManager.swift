import Foundation
import AVFoundation
import SwiftUI
import Combine
import OSLog

class CameraManager: NSObject, ObservableObject {
    private let logger = Logger(subsystem: "com.checkkicks.app", category: "CameraManager")
    @Published var session = AVCaptureSession()
    @Published var capturedImage: UIImage?
    @Published var isFlashOn = false
    @Published var setupError: String?
    @Published var isReady = false
    @Published var previewSize: CGSize = .zero

    private let output = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupSession()
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                self.setupError = "Camera access denied"
            }
        }
    }
    
    private func setupSession() {
        if session.isRunning {
            isReady = true
            return
        }
        
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            setupError = "No camera found"
            return
        }
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(videoDeviceInput!) {
                session.addInput(videoDeviceInput!)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            session.sessionPreset = .photo
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isReady = true
                }
            }
        } catch {
            session.commitConfiguration()
            setupError = "Setup failed: \(error.localizedDescription)"
        }
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }

    /// Crops the captured image to a 1:1 square (center crop).
    /// This ensures photos display correctly in the grid without unexpected cropping.
    private func cropToSquare(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        // Use PIXEL dimensions from cgImage
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)

        // Crop to center square (1:1 aspect ratio)
        let sideLength = min(imageWidth, imageHeight)
        let xOffset = (imageWidth - sideLength) / 2
        let yOffset = (imageHeight - sideLength) / 2

        let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength)

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return image
        }

        return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    func takePhoto() {
        guard isReady else { return }
        let settings = AVCapturePhotoSettings()
        if let connection = output.connection(with: .video), connection.isActive {
            settings.flashMode = isFlashOn ? .on : .off
            output.capturePhoto(with: settings, delegate: self)
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            logger.error("Capture error: \(error.localizedDescription)")
            return
        }
        
        guard let data = photo.fileDataRepresentation(), var image = UIImage(data: data) else {
            return
        }
        
        // Normalize orientation and crop to 1:1 square for consistent display
        image = image.normalizedOrientation()
        image = cropToSquare(image)
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}


struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    @Binding var previewSize: CGSize

    func makeUIView(context: Context) -> UIView {
        let view = PreviewView()
        view.backgroundColor = .black
        view.session = session
        view.onSizeChange = { size in
            DispatchQueue.main.async {
                previewSize = size
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Frame updates happen automatically via PreviewView's layoutSubviews
    }
}

// Custom UIView that properly manages AVCaptureVideoPreviewLayer frame
private class PreviewView: UIView {
    var session: AVCaptureSession? {
        didSet {
            if let session = session {
                previewLayer.session = session
            }
        }
    }

    var onSizeChange: ((CGSize) -> Void)?

    private var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Use .resizeAspectFill to fill the container (square preview)
        // Combined with a square container, this shows exactly what cropToSquare() captures
        previewLayer.videoGravity = .resizeAspectFill
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        previewLayer.videoGravity = .resizeAspectFill
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        onSizeChange?(bounds.size)
    }
}
