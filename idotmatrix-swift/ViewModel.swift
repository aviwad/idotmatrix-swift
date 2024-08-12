//
//  ViewModel.swift
//  idotmatrix-swift
//
//  Created by Avi Wadhwa on 2024-08-08.
//

import Foundation
import CoreBluetooth
import SwiftBluetooth

@Observable class ViewModel {
    let central: CentralManager
    var deviceStatus: DeviceStatusEnum = .on
    var device: Peripheral? = nil
    var calendar = Calendar.current
    var character: CBCharacteristic?
    
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
    
    // Fullscreen Color & Clock
    var red: Double {
        get {
            access(keyPath: \.red)
            return UserDefaults.standard.double(forKey: "red")
        }
        set {
            withMutation(keyPath: \.red) {
                UserDefaults.standard.setValue(newValue, forKey: "red")
            }
        }
    }
    var green: Double {
        get {
            access(keyPath: \.green)
            return UserDefaults.standard.double(forKey: "green")
        }
        set {
            withMutation(keyPath: \.green) {
                UserDefaults.standard.setValue(newValue, forKey: "green")
            }
        }
    }
    var blue: Double {
        get {
            access(keyPath: \.blue)
            return UserDefaults.standard.double(forKey: "blue")
        }
        set {
            withMutation(keyPath: \.blue) {
                UserDefaults.standard.setValue(newValue, forKey: "blue")
            }
        }
    }
//    var green = 0.0
//    var blue = 0.0
    
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
        calendar.firstWeekday = 2
        searchAgain()
    }
    
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
        let data = Data([7,0,2,2,UInt8(self.red),UInt8(self.green),UInt8(self.blue)])
        sendData(data: data)
    }
}

// Clock
extension ViewModel {
    func setClock() {
        let data = Data([8,0,6,1,UInt8(clockStyle | (visibleDate ? 128 : 0) | (hour24 ? 64 : 0)) ,UInt8(self.red),UInt8(self.green),UInt8(self.blue)])
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
}
