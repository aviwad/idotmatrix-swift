//
//  Common.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//
import Foundation
// Display Settings
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
