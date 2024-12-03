//
//  FullscreenColor.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//
import Foundation
// Fullscreen Color
extension ViewModel {
    func setFullScreenColor() {
        currentlyDisplayingImage = .notImage
//        let data = Data([7,0,2,2,UInt8(self.red),UInt8(self.green),UInt8(self.blue)])
        let data = Data([7,0,2,2,UInt8(self.color.redComponent*255),UInt8(self.color.greenComponent*255),UInt8(self.color.blueComponent*255)])
        sendData(data: data)
    }
}
