//
//  SleepWakeIntegration.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//

import Foundation

extension ViewModel {
    @objc func handleSleep(notification: Notification) {
//        print("disconnecting due to sleep")
        guard let device else {
            return
        }
        central.cancelPeripheralConnection(device)
        // Disconnect so that I can connect with my phone in bed
        
    }
    
    @objc func handleWake(notification: Notification) {
//        print("reconnecting due to wake")
        // Connect cuz I forgot I disconnected at sleep
//        searchAgain()
        guard let device else {
            return
        }
        // Resets the image mode on connection
        currentlyDisplayingImage = .notImage
        central.connect(device)
    }
}
