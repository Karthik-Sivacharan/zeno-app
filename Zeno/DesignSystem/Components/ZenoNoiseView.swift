import SwiftUI

struct ZenoNoiseView: View {
    let opacity: Double
    
    // Generate the noise image once statically to avoid re-computation
    private static let noiseImage: UIImage = {
        let size = CGSize(width: 512, height: 512)
        return UIImage.generateNoise(size: size)
    }()
    
    init(opacity: Double = ZenoSemanticTokens.TextureIntensity.standard) {
        self.opacity = opacity
    }
    
    var body: some View {
        Image(uiImage: Self.noiseImage)
            .resizable(resizingMode: .tile)
            .ignoresSafeArea()
            .blendMode(.overlay)
            .opacity(opacity)
            .allowsHitTesting(false) // Background texture shouldn't block touches
    }
}

// MARK: - Noise Generation Helper
extension UIImage {
    fileprivate static func generateNoise(size: CGSize) -> UIImage {
        let width = Int(size.width)
        let height = Int(size.height)
        let bitsPerComponent = 8
        let bytesPerPixel = 4 // RGBA
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow
        
        var data = [UInt8](repeating: 0, count: totalBytes)
        
        // Fill with random noise (grayscale)
        for i in 0..<width * height {
            let offset = i * bytesPerPixel
            let value = UInt8.random(in: 0...255)
            // We can just set R, G, B to the same value for grayscale, 
            // but for "overlay" blend mode, 50% gray is neutral. 
            // Random values around 128 gives the noise effect.
            
            data[offset] = value     // R
            data[offset + 1] = value // G
            data[offset + 2] = value // B
            data[offset + 3] = 255   // Alpha (Full opaque, we handle opacity in SwiftUI)
        }
        
        guard let provider = CGDataProvider(data: Data(data) as CFData),
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let cgImage = CGImage(
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bitsPerPixel: 32,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                provider: provider,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent
              ) else {
            return UIImage()
        }
        
        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    ZStack {
        Color.black
        ZenoNoiseView(opacity: 0.5)
    }
}



