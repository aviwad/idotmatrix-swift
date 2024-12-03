//
//  Gif.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//

import Foundation
import zlib
import AppKit

// Gif
extension ViewModel {
    @MainActor
    func selectGif() async -> URL? {
        NSApp.setActivationPolicy(.regular)
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker =  NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .resizable, backing: .buffered, defer: false)
        folderPicker.title = "Select a GIF Image"
        folderPicker.allowedContentTypes = [.gif] // Only allow .gif files
        folderPicker.allowsMultipleSelection = false // Only allow a single selection
        folderPicker.canChooseFiles = true // Allow file selection
        folderPicker.canChooseDirectories = false // Disallow directory selection
        NSApplication.shared.activate(ignoringOtherApps: true)
        let response = await folderPicker.begin()
        NSApp.setActivationPolicy(.accessory)
        if response == .OK {
            return folderPicker.url
        }
        return nil
    }
    
    func sendGif(_ gifData: Data) async {
        currentlyDisplayingImage = .notImage
        var chunks: [Data] = []
           
        // Initial header based on Python example - create ONCE
        let headerTemplate = Data([255, 255, 1, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 5, 0, 13])
        let hexString = headerTemplate.map { String(format: "%02x", $0) }.joined(separator: "")
        print(hexString)
        // Split GIF data into chunks first, just like Python
        let gifChunks = stride(from: 0, to: gifData.count, by: 4096).map {
            gifData.subdata(in: $0..<min($0 + 4096, gifData.count))
        }
        
        for (i, chunk) in gifChunks.enumerated() {
            // Create a copy of the header template for this chunk
            var header = headerTemplate
            
            // If it's not the first chunk, set byte 4 to 2
            header[4] = i > 0 ? 2 : 0
            
            // Set chunk length (INCLUDING header length) in first 2 bytes
            let chunkLen = UInt16(chunk.count + header.count)
            header.replaceSubrange(0..<2, with: withUnsafeBytes(of: chunkLen.littleEndian) { Data($0) })
            
            // Set total gif length - this stays the same for all chunks
            let gifLength = UInt32(gifData.count)
            header.replaceSubrange(5..<9, with: withUnsafeBytes(of: gifLength.littleEndian) { Data($0) })
            
            // Set CRC - this stays the same for all chunks
            let crc = UInt32(crc32(0, Array(gifData), UInt32(gifData.count)) & 0xFFFFFFFF)
            header.replaceSubrange(9..<13, with: withUnsafeBytes(of: crc.littleEndian) { Data($0) })
            
            // Combine header and chunk
            var chunkData = Data()
            chunkData.append(header)
            print("header")
            let hexString = header.map { String(format: "%02x", $0) }.joined(separator: "")
            print(hexString)
//            7008010000600800005a5175530000000005000d
//            7008010000600800005a51755305000d
//            700801000060080000ffffffff05000d
            chunkData.append(chunk)
            chunks.append(chunkData)
        }
                
        // Send chunks with delay
        for chunk in chunks {
            
            let hexString = chunk.map { String(format: "%02x", $0) }.joined(separator: "")
            print(hexString)
            print("Sending chunk of size: \(chunk.count)")  // Add debugging
            sendData(data: chunk)
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
        }
    }
    
}
