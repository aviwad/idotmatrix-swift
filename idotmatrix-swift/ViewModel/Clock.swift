//
//  Clock.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//
import Foundation
// Clock
extension ViewModel {
    func setClock() {
        currentlyDisplayingImage = .notImage
        print("clock style is \(clockStyle)")
//        let data = Data([8,0,6,1,UInt8(clockStyle | (visibleDate ? 128 : 0) | (hour24 ? 64 : 0)) ,UInt8(self.red),UInt8(self.green),UInt8(self.blue)])
        let data = Data([8,0,6,1,UInt8(clockStyle | (visibleDate ? 128 : 0) | (hour24 ? 64 : 0)),UInt8(self.color.redComponent*255),UInt8(self.color.greenComponent*255),UInt8(self.color.blueComponent*255)])
        sendData(data: data)
    }
    // TODO: setTimeIndicator,
}
