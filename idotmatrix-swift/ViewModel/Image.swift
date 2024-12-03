//
//  Image.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//

import Foundation
import AppKit

// Image
extension ViewModel {
    @MainActor
    func selectImage() async -> URL? {
        NSApplication.shared.activate(ignoringOtherApps: true)
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker =  NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .resizable, backing: .buffered, defer: true)
        folderPicker.title = "Select an Image (png only)"
        folderPicker.allowedContentTypes = [.image] // Only allow .gif files
        folderPicker.allowsMultipleSelection = false // Only allow a single selection
        folderPicker.canChooseFiles = true // Allow file selection
        folderPicker.canChooseDirectories = false // Disallow directory selection
        let response = await folderPicker.begin()
        if response == .OK {
            return folderPicker.url
        }
        return nil
    }
    
    func photoButtonClicked(data: Data? = nil) async {
        defer {
            photoUrl = nil
        }
        if let data = data {
            photoUrl = FileManager.default.temporaryDirectory.appendingPathComponent("downloaded.png")
            do {
                try data.write(to: photoUrl!)
            } catch {
                print("Failed to save downloaded PNG: \(error)")
                return
            }
        } else {
            photoUrl = await selectImage()
        }
        if let photoUrl = photoUrl{
            let process = Process()
            let pipe = Pipe()
//                            let bundle = Bundle.main
            let outputUrl = FileManager.default.temporaryDirectory.appendingPathComponent("output.png", conformingTo: .png)
            process.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
            process.arguments = ["-s", "format", "png", "-z", "32", "32", photoUrl.path, "--out", outputUrl.path]
//                            process.arguments = ["--resize", "\(32)x\(32)", photoUrl.path()]
            process.standardOutput = pipe
            do {
                try process.run()
                process.waitUntilExit()
//                                let outputData = pipe.fileHandleForReading.availableData
//                                await viewModel.sendPhoto(outputData)
                if process.terminationStatus == 0 {
                    if let outputData = try? Data(contentsOf: outputUrl) {
//                        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
//                        let fileUrl = documentsUrl.appendingPathComponent("foo.png")
//                        try! image.write(to: fileUrl)
                        await sendPhoto(outputData)
                       
                        
//                                        await viewModel.sendPhoto(try! adjustColorsInPNG(outputData, redBoost: 2, greenBoost: 1.2, blueReduction: 0.5))
                    } else {
                        print("Failed to read output file at \(outputUrl.path)")
                    }
                } else {
                    print("sips command failed with exit code \(process.terminationStatus)")
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func sendPhoto(_ photoData: Data) async {
        var chunks: [Data] = []

        // Split PNG data into chunks of 4096 bytes
        let chunkSize = 4096
        let pngChunks = stride(from: 0, to: photoData.count, by: chunkSize).map {
            photoData.subdata(in: $0..<min($0 + chunkSize, photoData.count))
        }
        
        // Calculate the "idk" value from Python: total PNG size + number of chunks
        let idk = Int16(photoData.count + pngChunks.count)
        let idkBytes = withUnsafeBytes(of: idk.littleEndian) { Data($0) }
        
        // PNG data size as a 32-bit integer
        let pngLenBytes = withUnsafeBytes(of: Int32(photoData.count).littleEndian) { Data($0) }
        
        for (i, chunk) in pngChunks.enumerated() {
            // Construct the header
            var header = Data()
            header.append(idkBytes) // Add the "idk" value
            
            // Add chunk-specific flags
            header.append(contentsOf: [0, 0, i > 0 ? 2 : 0]) // Set 3rd byte to 2 for subsequent chunks
            
            // Add the total PNG size
            header.append(pngLenBytes)
            
            // Combine header and chunk
            var chunkData = Data()
            chunkData.append(header)
            chunkData.append(chunk)
            chunks.append(chunkData)
        }

        // Send chunks
//        // get into image mode
        
        // send the image mode only if not already in image
        // Sending this unnecessarily introduces a second of black screen that sucks
        if currentlyDisplayingImage != .image {
            let imageModeData = Data([5,0,4,1,1])
            sendData(data: imageModeData)
            currentlyDisplayingImage = .image
        }
        for chunk in chunks {
//            let hexString = chunk.map { String(format: "%02x", $0) }.joined(separator: "")
//            print(hexString) // Debugging: print the chunk's hex representation
            print("Sending chunk of size: \(chunk.count)") // Debugging: show chunk size
            sendData(data: chunk, .withoutResponse) // Assuming `sendData` sends the data
//            try? await Task.sleep(nanoseconds: NSEC_PER_SEC) // Delay between sends
        }
    }
}
