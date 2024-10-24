//
//  DynamicBackgroundView.swift
//  DynamicColorBackground
//
//  Created by Yooku Anamuah-Mensah on 24/10/2024.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

#if os(iOS)
import UIKit
public typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
public typealias PlatformImage = NSImage
#endif

@available(iOS 14, macOS 10.15, *)
public struct DynamicBackgroundView: View {
    @State private var colors: [Color] = [.white, .gray] // Store extracted colors
    public var image: PlatformImage // Input image for color extraction
    
    public init(image: PlatformImage) {
        self.image = image
    }
    
    public var body: some View {
        ZStack {
            // Solid background with a defined gradient of distinct colors
            LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.9) // Adjust opacity for a more solid feel
            
            // Foreground content, like the album cover
            platformImageView(platformImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10) // Shadow effect
                .onAppear {
                    extractColors(from: image)
                }
        }
    }
    
    // Platform-specific image handling
    @ViewBuilder
    private func platformImageView(platformImage: PlatformImage) -> Image {
        #if os(iOS)
        Image(uiImage: platformImage)
        #elseif os(macOS)
        Image(nsImage: platformImage)
        #endif
    }

    // Function to extract a broad range of colors from the image
    private func extractColors(from image: PlatformImage) {
        #if os(iOS)
        guard let cgImage = image.cgImage else { return }
        #elseif os(macOS)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        #endif

        // Get image data
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        var rawData = [UInt8](repeating: 0, count: height * width * bytesPerPixel)
        let context = CGContext(data: &rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Extract colors by sampling pixels at intervals
        let sampleRate = 10 // Controls how many pixels we sample; lower value = more colors
        var sampledColors: [Color] = []
        
        for y in stride(from: 0, to: height, by: sampleRate) {
            for x in stride(from: 0, to: width, by: sampleRate) {
                let pixelIndex = (y * width + x) * bytesPerPixel
                let red = Double(rawData[pixelIndex]) / 255.0
                let green = Double(rawData[pixelIndex + 1]) / 255.0
                let blue = Double(rawData[pixelIndex + 2]) / 255.0

                let color = enhanceColor(red: red, green: green, blue: blue)
                sampledColors.append(Color(red: color.0, green: color.1, blue: color.2))
            }
        }

        // Reduce to a smaller set of distinct colors
        let distinctColors = Array(Set(sampledColors)).prefix(5).map { $0 } // Take first 5 distinct colors

        DispatchQueue.main.async {
            self.colors = distinctColors
        }
    }

    // Function to slightly enhance the color by adjusting brightness
    private func enhanceColor(red: Double, green: Double, blue: Double) -> (Double, Double, Double) {
        // Mild brightness boost
        let brightnessBoost = 1.1
        return (min(red * brightnessBoost, 1.0), min(green * brightnessBoost, 1.0), min(blue * brightnessBoost, 1.0))
    }
}

#if os(macOS)
// Helper extension to convert NSImage to CGImage
extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: self.size)
        return self.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)
    }
}
#endif
