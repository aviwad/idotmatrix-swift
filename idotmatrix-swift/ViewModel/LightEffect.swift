//
//  LightEffect.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//
import Foundation
// Light Effect
extension ViewModel {
    func setLightEffect() {
        currentlyDisplayingImage = .notImage
        // total count = 7 + 3(colors)
        let totalCount = 7 + (3 * lightEffectColor.count)
//        let data = Data([UInt8(totalCount),0,0,3,2,UInt8(lightEffectStyle),90,UInt8(lightEffectColor.count), UInt8(self.color.redComponent*255),UInt8(self.color.greenComponent*255),UInt8(self.color.blueComponent*255)])
        var data = Data([UInt8(totalCount), 0, 3, 2, UInt8(lightEffectStyle), 90, UInt8(lightEffectColor.count)])

        for color in lightEffectColor {
            data.append(UInt8(color.redComponent * 255))
            data.append(UInt8(color.greenComponent * 255))
            data.append(UInt8(color.blueComponent * 255))
        }
        sendData(data: data)
    }
}
