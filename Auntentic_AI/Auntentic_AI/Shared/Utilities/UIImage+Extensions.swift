import UIKit

extension UIImage {
    /// Normalizes image orientation to .up
    func normalizedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
    
    /// Crops image to a center-focused square
    func croppedToSquare() -> UIImage {
        let sideLength = min(size.width, size.height)
        let xOffset = (size.width - sideLength) / 2.0
        let yOffset = (size.height - sideLength) / 2.0
        let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength)
        
        if let cgImage = cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        }
        return self
    }
}
