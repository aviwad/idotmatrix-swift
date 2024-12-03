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
//import zlib
import ScriptingBridge

@Observable class ViewModel: ObservableObject {
    // Bluetooth Device
    let central: CentralManager
    var deviceStatus: DeviceStatusEnum = .on
    var device: Peripheral? = nil
    var character: CBCharacteristic?
    
    // Current Time
    var calendar = Calendar.current
    
    // Music Integration
    var spotifyScript: SpotifyApplication? = SBApplication(bundleIdentifier: "com.spotify.client")
    // Current focused menu
    var currentScreen = possibleScreens.home
    
    // If in device image mode
    var currentlyDisplayingImage: inImageModeEnum = .notImage
    
    // Singleton
    static let shared = ViewModel()
    
    // Common / Display Settings
    var screenTurnedOn = true
    var screenFlip = false
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
    
    // Fullscreen Color & Clock
    var color = DynamicColor.init(r: UserDefaults.standard.double(forKey: "red"), g: UserDefaults.standard.double(forKey: "green"), b: UserDefaults.standard.double(forKey: "blue"))
    
    // Gif Image
    var gifUrl: URL?
    
    // Music Integration
    var currentArtworkUrlString = ""
    
    // Image
    var photoUrl: URL?
    
    // Light Effect
    var lightEffectColorSelected = 0
    var lightEffectColor: [DynamicColor]
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
    
    // Text
    // text color: use existing clock/fullscreen color
    // text background color
    // text speed
    // font size
    // actual text to send
    // font path
    // text mode
    // text color mode
    // text background color mode
     
    
    // Clock
    var visibleDate = false
    var hour24 = true
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

    init() {
        central = CentralManager()
        lightEffectColor = []
//        let container = try! ModelContainer(for: AlbumArt.self)
//        modelContext = container.mainContext
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
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(handleSpotifyUpdate(notification:)), name: Notification.Name("com.spotify.client.PlaybackStateChanged"), object: nil, suspensionBehavior: .deliverImmediately)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(handleSleep(notification:)), name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(handleWake(notification:)), name: NSWorkspace.didWakeNotification, object: nil)
    }
    
    deinit {
        DistributedNotificationCenter.default().removeObserver(self, name: Notification.Name("LyricFeverColorUpdate"), object: nil)
        DistributedNotificationCenter.default().removeObserver(self, name: Notification.Name("com.spotify.client.PlaybackStateChanged"), object: nil)
        NSWorkspace.shared.notificationCenter.removeObserver(self, name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.removeObserver(self, name: NSWorkspace.didWakeNotification, object: nil)
    }
    
    func sendData(data: Data, _ withResponse: CBCharacteristicWriteType = .withoutResponse) {
        guard let character else {
            return
        }
        device?.writeValue(data, for: character, type: withResponse)
    }
    
    func searchAgain() {
        Task {
            try await central.waitUntilReady()
            let peripherals = await central.scanForPeripherals(timeout: 5)
            deviceStatus = .searching
            for try await peripheral in peripherals {
                if peripheral.name?.hasPrefix("IDM-") == true {
                    device = peripheral
                    print("we found our device!")
                    do {
                        try await central.connect(device!, timeout: 5)
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
                }
            }
            deviceStatus = .on
        }
    }
    
    func disconnect() {
        defer {
            deviceStatus = .on
            character = nil
            screenTurnedOn = true
            screenFlip = false
        }
        guard let device else {
            return
        }
        print("canceled peripheral connection")
        central.cancelPeripheralConnection(device)
        self.device = nil
    }
}
