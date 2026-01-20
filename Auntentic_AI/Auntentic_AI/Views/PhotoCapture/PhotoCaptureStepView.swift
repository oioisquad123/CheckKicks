import SwiftUI

// This view is deprecated. The app now uses AegisAdvancedCameraView for a faster 6-photo flow.
// This empty shell is kept to prevent Xcode project reference errors.
struct PhotoCaptureStepView: View {
    let step: PhotoCaptureStep
    @Binding var capturedImage: UIImage?
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        EmptyView()
    }
}
