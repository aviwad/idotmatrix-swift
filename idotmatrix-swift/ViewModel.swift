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
    var character: CBCharacteristic?
    var brightness = 5.0
    var deviceStatus: DeviceStatusEnum = .on
    var device: Peripheral? = nil
    //var peripherals: [Peripheral]
    //    enum deviceStatusEnum: String {
    //        case on = "Just Turned On"
    //        case searching = "Searching.."
    //        case found = "Found a device!"
    //        case connected = "Connected!"
    //        case error = "Error"
    //    }
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
    
    init() {
        central = CentralManager()
        searchAgain()
    }
    
    func setBrightness() {
        guard let character else {
            return
        }
        print(UInt8(brightness))
        let data = Data([5, 0, 4, 128, UInt8(brightness)])
        device?.writeValue(data, for: character, type: .withoutResponse)
    }
    
    func searchAgain() {
        Task {
            try await central.waitUntilReady()
            let peripherals = await central.scanForPeripherals()
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
                    deviceStatus = .connected
                    print("services: \(device?.services)")
                    print("state: \(device?.state.rawValue)")
                    print("can send without response: \(device?.canSendWriteWithoutResponse)")
                    if let service = try await device?.discoverServices().first, let character = try? await peripheral.discoverCharacteristics(for: service).first {
                        self.character = character
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
            return
        }
        central.cancelPeripheralConnection(device)
        self.device = nil
        deviceStatus = .on
        character = nil
    }
    
//    func connectToDevice() async {
//        guard let device else {
//            return
//        }
//    }
}
