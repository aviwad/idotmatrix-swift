//
//  Chronograph.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//
import Foundation

// Chronograph
extension ViewModel {
    func setChronograph() {
        currentlyDisplayingImage = .notImage
        let data = Data([5,0,9,128,UInt8(chronographMode.rawValue)])
        sendData(data: data)
    }
}
