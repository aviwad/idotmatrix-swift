//
//  Countdown.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//

import Foundation

// Countdown
extension ViewModel {
    func setCountdown() {
        currentlyDisplayingImage = .notImage
        let data = Data([7,0,8,128,UInt8(countdownMode.rawValue),UInt8(minutes),UInt8(seconds)])
        sendData(data: data)
    }
}
