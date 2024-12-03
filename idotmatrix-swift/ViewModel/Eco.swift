//
//  Eco.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//

import Foundation

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

