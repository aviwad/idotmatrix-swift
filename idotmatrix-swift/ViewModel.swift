//
//  ViewModel.swift
//  idotmatrix-swift
//
//  Created by Avi Wadhwa on 2024-08-08.
//

import Foundation
import CoreBluetooth
import SwiftBluetooth
import DynamicColor
import AppKit
import zlib

@Observable class ViewModel: ObservableObject {
    let central: CentralManager
    var deviceStatus: DeviceStatusEnum = .on
    
//    var switchDisconnectSubscription: AsyncSubscription<PeripheralEvent>
    var device: Peripheral? = nil
    var calendar = Calendar.current
    var character: CBCharacteristic?
    var currentScreen = possibleScreens.home
    static let shared = ViewModel()
    
    enum possibleScreens {
        case common
        case fullscreenColor
        case gifImage
        case image
        case text
        case lightEffect
        case clock
        case stopwatch
        case timer
        case eco
        case musicIntegration
        case home
    }
    
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
    
    @MainActor
    func selectImage() async -> URL? {
        NSApplication.shared.activate(ignoringOtherApps: true)
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker =  NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .resizable, backing: .buffered, defer: true)
        folderPicker.title = "Select an Image (png only)"
        folderPicker.allowedContentTypes = [.png] // Only allow .gif files
        folderPicker.allowsMultipleSelection = false // Only allow a single selection
        folderPicker.canChooseFiles = true // Allow file selection
        folderPicker.canChooseDirectories = false // Disallow directory selection
        let response = await folderPicker.begin()
        if response == .OK {
            return folderPicker.url
        }
        return nil
    }
    
    // Common
    var brightness: Double {
        get {
            access(keyPath: \.brightness)
            return UserDefaults.standard.double(forKey: "brightness")
        }
        set {
            withMutation(keyPath: \.brightness) {
                UserDefaults.standard.setValue(newValue, forKey: "brightness")
            }
        }
    }
    var screenTurnedOn = true
    var screenFlip = false
//    
//    // Fullscreen Color & Clock
    var color = DynamicColor.init(r: UserDefaults.standard.double(forKey: "red"), g: UserDefaults.standard.double(forKey: "green"), b: UserDefaults.standard.double(forKey: "blue"))
//    var red: Double {
//        get {
//            access(keyPath: \.red)
//            return UserDefaults.standard.double(forKey: "red")
//        }
//        set {
//            withMutation(keyPath: \.red) {
//                UserDefaults.standard.setValue(newValue, forKey: "red")
//            }
//        }
//    }
//    var green: Double {
//        get {
////            return 1
//            access(keyPath: \.green)
//            return UserDefaults.standard.double(forKey: "green")
//        }
//        set {
//            withMutation(keyPath: \.green) {
//                UserDefaults.standard.setValue(newValue, forKey: "green")
//            }
//        }
//    }
//    var blue: Double {
//        get {
////            return 1
//            access(keyPath: \.blue)
//            return UserDefaults.standard.double(forKey: "blue")
//        }
//        set {
//            withMutation(keyPath: \.blue) {
//                UserDefaults.standard.setValue(newValue, forKey: "blue")
//            }
//        }
//    }
//    var green = 0.0
//    var blue = 0.0
    
    // Gif Image
    var gifUrl: URL?
    
    func sendGif(_ gifData: Data) async {
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
    
    func sendGif69(_ gifData: Data) async {
        // divide gifData into chunks of 4096
        
        
//        def _createPayloads(
//                self, gif_data: bytearray, chunk_size: int = 4096
//            ) -> List[bytearray]:
//                """Creates payloads from a GIF file.
//
//                Args:
//                    gif_data (bytearray): data of the gif file
//                    chunk_size (int): size of a chunk
//
//                Returns:
//                    bytearray: returns bytearray payload
//                """
//                # chunk header
//                header = bytearray(
//                    [
//                        255,
//                        255,
//                        1,
//                        0,
//                        0,
//                        255,
//                        255,
//                        255,
//                        255,
//                        255,
//                        255,
//                        255,
//                        255,
//                        5,
//                        0,
//                        13,
//                    ]
//                )
        
//        var header = Data([255, 255, 1, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 5, 0, 13])
        
//                # split gif into chunks
//                chunks = []
//                gif_chunks = self._splitIntoChunks(gif_data, chunk_size)
//                # set gif length
//                header[5:9] = int(len(gif_data)).to_bytes(4, byteorder="little")
//                # set crc of gif
//                crc = zlib.crc32(gif_data)
//                header[9:13] = crc.to_bytes(4, byteorder="little")
//                # iterate over chunks
//                for i, chunk in enumerate(gif_chunks):
//                    # starting from the second chunk, set the header to 2
//                    header[4] = 2 if i > 0 else 0
//                    # set chunk length in header
//                    chunk_len = len(chunk) + len(header)
//                    header[0:2] = chunk_len.to_bytes(2, byteorder="little")
//                    # append chunk to chunk list
//                    chunks.append(header + chunk)
//                return chunks
        
//        let chunkSize: Int = 4096
//        let chunks: [Data] = [gifData]
//        for chunk in chunks {
//            sendData(data: chunk)
//            try? await Task.sleep(nanoseconds: 1000)
//        }
        
        var chunks: [Data] = []
           
           // Initial header based on Python example
           var header = Data([255, 255, 1, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 5, 0, 13])
           
           // Set GIF length in the header (bytes 5-8)
           let gifLength = gifData.count
           header.replaceSubrange(5..<9, with: withUnsafeBytes(of: UInt32(gifLength).littleEndian) { Data($0) })
           
           // Calculate CRC and set it in the header (bytes 9-12)
           let crc = crc32(0, Array(gifData), UInt32(gifLength))
           header.replaceSubrange(9..<13, with: withUnsafeBytes(of: crc.littleEndian) { Data($0) })
           
           // Split GIF data into chunks
           let gifChunks = stride(from: 0, to: gifData.count, by: 4000).map {
               gifData.subdata(in: $0..<min($0 + 4000, gifData.count))
           }
           
           // Create payloads for each chunk
           for (i, chunk) in gifChunks.enumerated() {
               // Set the header's 4th byte to 2 if it's not the first chunk
               header[4] = i > 0 ? 2 : 0
               
               // Set chunk length (2 bytes, little-endian) at start of header
               let chunkLen = UInt16(header.count + chunk.count)
               header.replaceSubrange(0..<2, with: withUnsafeBytes(of: chunkLen.littleEndian) { Data($0) })
               
               // Combine header and chunk, then add to list of chunks
               var chunkData = Data()
               chunkData.append(header)
               chunkData.append(chunk)
               chunks.append(chunkData)
           }
           
//           return chunks
                for chunk in chunks {
                    sendData(data: chunk)
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
                }
    }
    
    
    // Image
    var photoUrl: URL?
    
    // Light Effect
    var lightEffectStyle: Int {
        get {
            access(keyPath: \.lightEffectStyle)
            return UserDefaults.standard.integer(forKey: "lightEffectStyle")
        }
        set {
            withMutation(keyPath: \.lightEffectStyle) {
                UserDefaults.standard.setValue(newValue, forKey: "lightEffectStyle")
            }
        }
    }
    
    var lightEffectColorSelected = 0
    
    var lightEffectColor: [DynamicColor]
    
//    func initLightEffectColor() -> [DynamicColor] {
//        var lightEffectColor: [DynamicColor] = []
//    }
    
    // Clock
    var clockStyle: Int {
        get {
            access(keyPath: \.clockStyle)
            return UserDefaults.standard.integer(forKey: "clockStyle")
        }
        set {
            withMutation(keyPath: \.clockStyle) {
                UserDefaults.standard.setValue(newValue, forKey: "clockStyle")
            }
        }
    }
    var visibleDate = false
    var hour24 = true
    
    // Chronograph
    var chronographMode = chronographModeEnum.reset
    
    // Eco
    var startUpDate = Date()
    var endDate = Date()
    var ecoBrightness = 50.0
    
    enum chronographModeEnum: Int {
        case reset = 0
        case start = 1
        case pause = 2
        case unpause = 3
    }
    
    // Countdown
    var countdownMode = countdownModeEnum.disable
    var minutes = 0.0
    var seconds = 0.0
    enum countdownModeEnum: Int {
        case disable = 0
        case start = 1
        case pause = 2
        case unpause = 3
    }

    enum DeviceStatusEnum: Equatable {
        case on
        case searching
        case connected
        case error(String) // Associated value to store the error message
    }
    
    var statusDescription: String {
        switch deviceStatus {
        case .on:
            return "Disconnected"
        case .searching:
            return "Searching.."
        case .connected:
            guard let name = device?.name else {
                return "Fail"
            }
            return "Connected to \(name)"
        case .error(let errorMessage):
            return "Error: \(errorMessage)"
        }
    }
    
    var labelIconSystemImage: String {
        switch deviceStatus {
        case .on:
            "xmark.icloud.fill"
        case .searching:
            "magnifyingglass"
        case .connected:
            "checkmark.icloud.fill"
        case .error(_):
            "exclamationmark.icloud.fill"
        }
    }
    
    init() {
        central = CentralManager()
        lightEffectColor = []
        let lightEffectColorCount = UserDefaults.standard.integer(forKey: "lightEffectCount")
        for i in 0..<lightEffectColorCount {
            let red = UserDefaults.standard.double(forKey: "redLightEffect\(i)")
            let green = UserDefaults.standard.double(forKey: "greenLightEffect\(i)")
            let blue = UserDefaults.standard.double(forKey: "blueLightEffect\(i)")
            print("rgb: \(red), \(green), \(blue)")
            if red > 0 || green > 0 || blue > 0 {
                let color: DynamicColor = .init(r: red, g: green, b: blue)
                lightEffectColor.append(color)
            }
        }
        if lightEffectColor.isEmpty {
            lightEffectColor.append(.red)
            lightEffectColor.append(.blue)
        }
        print("lightEffectColor is \(lightEffectColor)")
        calendar.firstWeekday = 2
        print("calling search again from init")
        searchAgain()
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(handleColorUpdate(notification:)), name: Notification.Name("LyricFeverColorUpdate"), object: nil, suspensionBehavior: .deliverImmediately)
//        receiveLyricFeverInput()
    }
    
    deinit {
        DistributedNotificationCenter.default().removeObserver(self, name: Notification.Name("LyricFeverColorUpdate"), object: nil)
    }
    
    @objc private func handleColorUpdate(notification: Notification) {
        print("RECEIVED NOTIFICATION")
                
                if let jsonString = notification.object as? String,
                   let jsonData = jsonString.data(using: .utf8),
                   let colorData = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: CGFloat],
                   let red = colorData["red"],
                   let green = colorData["green"],
                   let blue = colorData["blue"] {
                    
                    
                    
                    // Update color properties based on logic
//                    self.color = .init(r: blue > red ? red * 255 : min(red * 450, 255), g: blue > green ? green * 255 : min(green * 260, 255), b: blue * 255)
//                    self.color = .init(r: blue > red ? red : min(red * 1.7, 255), g: blue > green ? green : min(green * 1.5, 255), b: (red > blue || green > blue) ? min(blue * 0.5, blue) : blue)
//                    self.color = .init(
//                        r: min(red * (blue > red ? 1.8 : 2.5), 255),   // Boost red more strongly for orange hues
//                        g: min(green * (blue > green ? 1.6 : 2.0), 255), // Keep green scaling moderate but distinct
//                        b: (red > blue || green > blue) ? min(blue * 0.2, 100) : min(blue * 0.6, 180) // Further cap blue when red or green is stronger
//                    )
                    self.color = .init(
                        r: red > green ? min(red * (blue > red ? 1.8 : 2.5), 255) : min(red * 1.2, 255), // Boost red only if it’s higher than green
                        g: green > red ? min(green * (blue > green ? 1.7 : 2.3), 255) : min(green * 1.2, 255), // Boost green only if it’s higher than red
                        b: (red > blue || green > blue) ? min(blue * 0.25, 128) : min(blue * 0.8, 200) // Cap blue to prevent it from overpowering
                    )
//                    self.color = .init(
//                        r: red > green ? min(red * (blue > red ? 2.0 : 2.8), 255) : min(red * 1.2, 255), // Stronger boost for red when it's dominant
//                        g: green > red ? min(green * (blue > green ? 2.0 : 2.5), 255) : min(green * 1.2, 255), // Stronger boost for green when it's dominant
//                        b: (red > blue || green > blue) ? min(blue * 0.2, 80) : min(blue * 0.8, 180) // More aggressive cap for blue when red or green are dominant
//                    )
//                    self.color = .init(
//                        r: blue > red ? min(red * 1.8, 255) : min(red * 2.2, 255),
//                        g: blue > green ? min(green * 1.7, 255) : min(green * 2.0, 255),
//                        b: (red > blue || green > blue) ? min(blue * 0.3, 128) : min(blue * 0.8, 200)
//                    )
//                    self.red = blue > red ? red * 255 : min(red * 450, 255)
//                    self.green = blue > green ? green * 255 : min(green * 260, 255)
//                    self.blue = blue * 255
                    
                    // Optional: Call any additional methods as needed
                    setClock()
                } else {
                    print("Failed to decode color data")
                }
    }
    
//    func receiveLyricFeverInput() {
//        DistributedNotificationCenter.default()
//            .publisher(for: Notification.Name("LyricFeverColorUpdate"))
//            .sink { [weak self] notification in
//                self?.handleColorUpdate(notification: notification)
//            }
//           // .store(in: &cancellables)
//    }
//    
//    private func handleColorUpdate(notification: Notification) {
//        // Handle the notification here
//        // Example: print the notification's userInfo
//        print(notification.object)
//    }
    
    func sendData(data: Data) {
        guard let character else {
            return
        }
        device?.writeValue(data, for: character, type: .withoutResponse)
    }
    
    func searchAgain() {
        Task {
            try await central.waitUntilReady()
            let peripherals = await central.scanForPeripherals(timeout: 5)
            deviceStatus = .searching
            for try await peripheral in peripherals {
                print("peripheral name: \(peripheral.name)")
                if peripheral.name?.hasPrefix("IDM-") == true {
                    device = peripheral
                    print("we found our device!")
                    do {
                        try await central.connect(device!, timeout: 5)
                        central.state
                        deviceStatus = .connected
                    } catch {
                        print(error)
                    }
                    if let service = try await device?.discoverServices().first, let character = try? await peripheral.discoverCharacteristics(for: service).first {
                        self.character = character
                        deviceStatus = .connected
                        try? await Task.sleep(nanoseconds: 100000000)
                        // Sync time and clock on connection
                        setClock()
                        setTime()
                        setBrightness()
                        cancelEco()
                    }
                    return
                    // device?.writeValue(<#T##data: Data##Data#>, for: .)
                }
            }
            deviceStatus = .on
        }
    }
    
    func disconnect() {
        guard let device else {
            deviceStatus = .on
            character = nil
            screenTurnedOn = true
            screenFlip = false
            return
        }
        print("canceled peripheral connection")
        central.cancelPeripheralConnection(device)
        self.device = nil
        deviceStatus = .on
        character = nil
        screenTurnedOn = true
        screenFlip = false
    }
}

// Common
extension ViewModel {
    func setBrightness() {
        let data = Data([5, 0, 4, 128, UInt8(brightness)])
        sendData(data: data)
    }
    
    func freezeScreen() {
        let data = Data([4,0,3,0])
        sendData(data: data)
    }
    
    func screenOff() {
        let data = Data([5,0,7,1,0])
        sendData(data: data)
        screenTurnedOn = false
    }
    
    func screenOn() {
        let data = Data([5,0,7,1,1])
        sendData(data: data)
        screenTurnedOn = true
    }
    
    func flipScreen() {
        let data = Data([5,0,6,128,screenFlip ? 0 : 1])
        screenFlip.toggle()
        sendData(data: data)
    }
    
    func setTime() {
        let year = UInt8(calendar.component(.year, from: Date()) % 100)
        let month = UInt8(calendar.component(.month, from: Date()))
        let day = UInt8(calendar.component(.day, from: Date()))
        let weekday = UInt8(calendar.component(.weekday, from: Date()))
        let hour = UInt8(calendar.component(.hour, from: Date()))
        let minute = UInt8(calendar.component(.minute, from: Date()))
        let second = UInt8(calendar.component(.second, from: Date()))
        let data = Data([11, 0, 1, 128, year, month, day, weekday, hour, minute, second])
        sendData(data: data)
    }
    
    // TODO: setJoint, setPassword, setSpeed
}

// Fullscreen Color
extension ViewModel {
    func setFullScreenColor() {
//        let data = Data([7,0,2,2,UInt8(self.red),UInt8(self.green),UInt8(self.blue)])
        let data = Data([7,0,2,2,UInt8(self.color.redComponent*255),UInt8(self.color.greenComponent*255),UInt8(self.color.blueComponent*255)])
        sendData(data: data)
    }
}

// Light Effect
extension ViewModel {
    func setLightEffect() {
        // total count = 7 + 3(colors)
        let totalCount = 7 + (3 * lightEffectColor.count)
//        let data = Data([UInt8(totalCount),0,0,3,2,UInt8(lightEffectStyle),90,UInt8(lightEffectColor.count), UInt8(self.color.redComponent*255),UInt8(self.color.greenComponent*255),UInt8(self.color.blueComponent*255)])
        var data = Data([UInt8(totalCount), 0, 3, 2, UInt8(lightEffectStyle), 90, UInt8(lightEffectColor.count)])

        for color in lightEffectColor {
            data.append(UInt8(color.redComponent * 255))
            data.append(UInt8(color.greenComponent * 255))
            data.append(UInt8(color.blueComponent * 255))
        }
        sendData(data: data)
    }
}

// Clock
extension ViewModel {
    func setClock() {
        print("clock style is \(clockStyle)")
//        let data = Data([8,0,6,1,UInt8(clockStyle | (visibleDate ? 128 : 0) | (hour24 ? 64 : 0)) ,UInt8(self.red),UInt8(self.green),UInt8(self.blue)])
        let data = Data([8,0,6,1,UInt8(clockStyle | (visibleDate ? 128 : 0) | (hour24 ? 64 : 0)),UInt8(self.color.redComponent*255),UInt8(self.color.greenComponent*255),UInt8(self.color.blueComponent*255)])
        sendData(data: data)
    }
    // TODO: setTimeIndicator,
}

// Chronograph
extension ViewModel {
    func setChronograph() {
        let data = Data([5,0,9,128,UInt8(chronographMode.rawValue)])
        sendData(data: data)
    }
}

// Countdown
extension ViewModel {
    func setCountdown() {
        let data = Data([7,0,8,128,UInt8(countdownMode.rawValue),UInt8(minutes),UInt8(seconds)])
        sendData(data: data)
    }
}

// Images
extension ViewModel {
    func setImage() {
        
    }
}

// Eco
extension ViewModel {
    func setEco() {
        // as per python3-idotmatrix-library, the flag is unknown and either a 1 or a 0
        // for now using 1 to set it
        let data = Data([10,0,2,128,1,UInt8(calendar.component(.hour, from: startUpDate)),UInt8(calendar.component(.minute, from: startUpDate)),UInt8(calendar.component(.hour, from: endDate)),UInt8(calendar.component(.minute, from: endDate)),UInt8(ecoBrightness)])
        sendData(data: data)
    }
    
    func cancelEco() {
        let data = Data([10,0,2,128,0,0,0,0,0,0])
        sendData(data: data)
    }
//        .onReceive(DistributedNotificationCenter.default().publisher(for: Notification.Name("LyricFeverColorUpdate")), perform: { notification in
//            print("RECEIVED NOTIFCIATION")
//            if let jsonString = notification.object as? String,
//                    let jsonData = jsonString.data(using: .utf8) {
//                     // Convert JSON string to dictionary
//                     if let colorData = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: CGFloat],
//                        let red = colorData["red"],
//                        let green = colorData["green"],
//                        let blue = colorData["blue"] {
//                         // Use the RGB values
//                         print("Received RGB values: red=\(red), green=\(green), blue=\(blue)")
//                         ViewModel.shared.red = blue > red ? red * 255 : min(red * 450, 255)
//                         ViewModel.shared.green = blue > green ? green * 255 : min(green * 260, 255)
//                         ViewModel.shared.blue = blue * 255
//                         ViewModel.shared.setClock()
//                     } else {
//                         print("Failed to decode color data")
//                     }
//                 } else {
//                     print("Notification object is not a valid JSON string")
//                 }
//        })
}

//extension Peripheral {
//    var switchDisconnectSubscription = self.eventSubscriptions.queue { event, done in
//        guard case .didDisconnect(let error) = event else { return }
//
//        print("did disconnect: \(String(describing: error))")
//    }
//}
