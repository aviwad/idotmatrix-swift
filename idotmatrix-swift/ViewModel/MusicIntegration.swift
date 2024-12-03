//
//  MusicIntegration.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//

import Foundation
import CoreImage

extension ViewModel {
    @objc func handleColorUpdate(notification: Notification) {
        if let jsonString = notification.object as? String,
           let jsonData = jsonString.data(using: .utf8),
           let colorData = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: CGFloat],
           let red = colorData["red"],
           let green = colorData["green"],
           let blue = colorData["blue"] {
            // Update color properties based on logic
            self.color = .init(
                r: red > green ? min(red * (blue > red ? 1.8 : 2.5), 255) : min(red * 1.2, 255), // Boost red only if it’s higher than green
                g: green > red ? min(green * (blue > green ? 1.7 : 2.3), 255) : min(green * 1.2, 255), // Boost green only if it’s higher than red
                b: (red > blue || green > blue) ? min(blue * 0.25, 128) : min(blue * 0.8, 200) // Cap blue to prevent it from overpowering
            )
            setClock()
        } else {
            print("Failed to decode color data")
        }
    }

    // Apply a color adjustment transformation to a CIImage
//    func adjustColors(of image: CIImage) -> CIImage? {
//        guard let cgImage = CIContext().createCGImage(image, from: image.extent) else {
//            print("Failed to create CGImage.")
//            return nil
//        }
//
//        let width = Int(image.extent.width)
//        let height = Int(image.extent.height)
//
//        let bytesPerPixel = 4
//        let bytesPerRow = bytesPerPixel * width
//        var pixelBuffer = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
//
//        // Create bitmap context for pixel manipulation
//        guard let context = CGContext(
//            data: &pixelBuffer,
//            width: width,
//            height: height,
//            bitsPerComponent: 8,
//            bytesPerRow: bytesPerRow,
//            space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
//            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
//        ) else {
//            print("Failed to create CGContext.")
//            return nil
//        }
//
//        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//
//        // Modify pixels
//        for y in 0..<height {
//            for x in 0..<width {
//                let offset = (y * width + x) * bytesPerPixel
//
//                let r = Float(pixelBuffer[offset + 0]) / 255.0
//                let g = Float(pixelBuffer[offset + 1]) / 255.0
//                let b = Float(pixelBuffer[offset + 2]) / 255.0
//
//                // Apply the weighted transformation
//                let newR = r * colorAdjustments["red"]!.red + g * colorAdjustments["green"]!.red + b * colorAdjustments["blue"]!.red
//                let newG = r * colorAdjustments["red"]!.green + g * colorAdjustments["green"]!.green + b * colorAdjustments["blue"]!.green
//                let newB = r * colorAdjustments["red"]!.blue + g * colorAdjustments["green"]!.blue + b * colorAdjustments["blue"]!.blue
//
//                // Clamp and update pixel values
//                pixelBuffer[offset + 0] = UInt8(max(0, min(255, newR * 255.0)))
//                pixelBuffer[offset + 1] = UInt8(max(0, min(255, newG * 255.0)))
//                pixelBuffer[offset + 2] = UInt8(max(0, min(255, newB * 255.0)))
//            }
//        }
//
//        // Create a new CIImage from the modified pixel buffer
//        guard let outputCGImage = context.makeImage() else {
//            print("Failed to create output CGImage.")
//            return nil
//        }
//
//        return CIImage(cgImage: outputCGImage)
//    }
    
    @objc func handleSpotifyUpdate(notification: Notification) {
        print("RECEIVED NOTIFICATION")
        Task {
            if let artworkUrlString = spotifyScript?.currentTrack?.artworkUrl {
                print("current artwork url: \(currentArtworkUrlString) and new: \(artworkUrlString)")
                if artworkUrlString != "" && currentArtworkUrlString != artworkUrlString {
                    currentArtworkUrlString = artworkUrlString
//                    if let albumArt = modelContext.model(for: .identifier(for: <#T##String#>, entityName: <#T##String#>, primaryKey: <#T##Comparable & CustomStringConvertible & Decodable & Encodable & Hashable#>)) as? AlbumArt {
//                        print(sneakers.director)
//                    }
                    if let artworkUrl = URL(string: artworkUrlString), let data = try? await URLSession.shared.data(from: artworkUrl) {
//                        let context = CIContext()
//                        if let ciImage = CIImage(data: data.0), let adjusted = adjustColors(of: ciImage), let image = context.pngRepresentation(of: adjusted, format: .RGBAh, colorSpace: CGColorSpace(name: CGColorSpace.dcip3)!) {
//                            await photoButtonClicked(data: image)
//                        }
                        
                        let ciImage = CIImage(data: data.0)
                        let filter = CIFilter(name: "CIColorControls")!
//                        let colorMatrixFilter = CIFilter.colorMatrix()
                        filter.setValue(ciImage, forKey: kCIInputImageKey)
                        filter.setValue(1.8, forKey: kCIInputSaturationKey)
//                        filter.setValue(CIVector(x: 1.2, y: 0, z: 0, w: 0), forKey: "inputRVector") // Increase red
//                            filter.setValue(CIVector(x: 0, y: 1.2, z: 0, w: 0), forKey: "inputGVector") // Increase green
//                            filter.setValue(CIVector(x: 0, y: 0, z: 0.8, w: 0), forKey: "inputBVector") // Decrease blue
//                            filter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector") // Preserve alpha
                        let context = CIContext()
                        guard let outputImage = filter.outputImage, let image = context.pngRepresentation(of: outputImage, format: .RGBAh, colorSpace: CGColorSpace(name: CGColorSpace.dcip3)!) else { return  }
//                        let albumArt = AlbumArt(id: artworkUrlString, albumArt: image)
//                        modelContext.insert(albumArt)
                        await photoButtonClicked(data: image)
                    }
                }
            }
        }
        
    }
}
