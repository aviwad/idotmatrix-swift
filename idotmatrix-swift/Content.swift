//
//  Content.swift
//  idotmatrix-swift
//
//  Created by Avi Wadhwa on 2024-08-11.
//

import SwiftUI
import CompactSlider
import ColorPickerRing

struct ContentWrapper: View {
    @State var viewModel = ViewModel.shared
    
    var body: some View {
        Content(viewModel: $viewModel)
        #if os(macOS)
            .frame(width: 350)
        #endif
    }
}

struct Content: View {
    @Binding var viewModel: ViewModel
    let elementSpacing = 8.0
    let groupSpacing = 9.0
    
    @ViewBuilder var common: some View {
        VStack(spacing: elementSpacing) {
            HStack {
                Button(action: {
                    viewModel.currentScreen = .home
                }, label: {
                    Image(systemName: "chevron.backward")
                })
                Text("Common Screen Behaviour")
                    .bold()
                Image(systemName: "display")
                    .font(.system(size: 24))
                    .frame(height: 40)
            }
            HStack {
                    if viewModel.screenTurnedOn {
                        Button("Off") {
                            viewModel.screenOff()
                        }
                    } else {
                        Button("On") {
                            viewModel.screenOn()
                        }
                    }
                    Button("Sync Time") {
                        viewModel.setTime()
                    }
                    Button("Freeze") {
                        viewModel.freezeScreen()
                    }
                    Button("Flip") {
                        viewModel.flipScreen()
                    }
            }
            CompactSlider(
                value: $viewModel.brightness,
                in: 5...100,
                step: 1
            ) {
                Text("Brightness")
                Spacer()
                Text(String(format: "%.0f%%", viewModel.brightness))
            }
            .frame(height: 24)
            .onChange(of: viewModel.brightness) {
                viewModel.setBrightness()
            }
        }
    }
    
    @ViewBuilder var fullscreenColor: some View {
        VStack(spacing: elementSpacing) {
            HStack {
                Button(action: {
                    viewModel.currentScreen = .home
                }, label: {
                    Image(systemName: "chevron.backward")
                })
                Text("Fullscreen Color")
                    .bold()
                Rectangle()
                    .fill(Color(viewModel.color))
                    .frame(width: 25, height: 25)
                    .cornerRadius(5)
                    .padding(.vertical, 7.5)
                    .padding(.trailing, 15)
            }
            CompactSlider(
                value: $viewModel.brightness,
                in: 5...100,
                step: 1
            ) {
                Text("Brightness")
                Spacer()
                Text(String(format: "%.0f%%", viewModel.brightness))
            }
            .frame(height: 24)
            .onChange(of: viewModel.brightness) {
                viewModel.setBrightness()
            }
            ColorPickerRing(color: $viewModel.color, strokeWidth: 30)
                        .frame(width: 200, height: 200, alignment: .center)
                        .onChange(of: viewModel.color) {
                            viewModel.setFullScreenColor()
                        }
        }
    }
    
    @ViewBuilder var gifImage: some View {
        VStack(spacing: elementSpacing) {
            HStack {
                Button(action: {
                    viewModel.currentScreen = .home
                }, label: {
                    Image(systemName: "chevron.backward")
                })
                Text("Gif Image")
                    .bold()
                Image(systemName: "photo.stack")
                    .font(.system(size: 24))
                    .frame(height: 40)
            }
            HStack {
                Button(action: {
                    Task {
                        defer {
                            viewModel.gifUrl = nil
                        }
                        viewModel.gifUrl = await viewModel.selectGif()
                        if let gifUrl = viewModel.gifUrl{
//                            await viewModel.sendGif(data)
                            let process = Process()
                            let pipe = Pipe()
                            let bundle = Bundle.main
                            let pathToExecutable = bundle.url(forResource: "gifsicle", withExtension: "")
                            process.executableURL = pathToExecutable
                            process.arguments = ["--resize", "\(32)x\(32)", gifUrl.path()]
                            process.standardOutput = pipe
                            do {
                                try process.run()
                                process.waitUntilExit()
                                let outputData = pipe.fileHandleForReading.availableData
                                await viewModel.sendGif(outputData)
//                                let output2 = pipe.fileHandleForReading.readDataToEndOfFile()
                                
                            } catch {
                                print(error)
                            }
                        }
                    }
                   // viewModel.showGif.toggle()
                }, label: {
                    Text("Select Gif")
                })
            }
            HStack {
                if let gifUrl = viewModel.gifUrl {
                    Text("Uploading \(gifUrl.lastPathComponent)")
                }
            }
        }
    }
    
    @ViewBuilder var image: some View {
        VStack(spacing: elementSpacing) {
            HStack {
                Button(action: {
                    viewModel.currentScreen = .home
                }, label: {
                    Image(systemName: "chevron.backward")
                })
                Text("Image")
                    .bold()
                Image(systemName: "photo.fill")
                    .font(.system(size: 24))
                    .frame(height: 40)
            }
            HStack {
                Button(action: {
                    Task {
                        viewModel.photoUrl = await viewModel.selectImage()
                        if let photoUrl = viewModel.photoUrl, let data = try? Data(contentsOf: photoUrl, options: .uncached) {
                            
                        }
                    }
                   // viewModel.showGif.toggle()
                }, label: {
                    Text("Select Image")
                })
            }
            HStack {
                if let photoUrl = viewModel.photoUrl {
                    Text(photoUrl.absoluteString)
                }
            }
        }
    }
    
    @ViewBuilder var text: some View {
        VStack(spacing: elementSpacing) {
            HStack {
                Button(action: {
                    viewModel.currentScreen = .home
                }, label: {
                    Image(systemName: "chevron.backward")
                })
                Text("Text")
                    .bold()
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 24))
                    .frame(height: 40)
            }
            HStack {
                Text("Work in progress")
            }
        }
    }

    @ViewBuilder func lightColor(index: Int) -> some View {
        Rectangle()
            .fill(index >= viewModel.lightEffectColor.count ? .clear : Color(viewModel.lightEffectColor[index]))
            .border(index == viewModel.lightEffectColorSelected ? Color.blue : Color.black, width: 5)
            .frame(width: 40, height: 40)
            .cornerRadius(5)
            .padding(.vertical, 7.5)
            .contentShape(Rectangle())
            .overlay() {
                if index == viewModel.lightEffectColorSelected && viewModel.lightEffectColor.count > 2 {
                    Image(systemName: "x.circle")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .frame(height: 40)
                        .frame(alignment: .center)
                }
            }
//            .onHover { isHover in
//                print(isHover)
//                isHovering = isHover
//            }
            .onTapGesture {
                if viewModel.lightEffectColorSelected == index {
                    if viewModel.lightEffectColor.count == 2 {
                        viewModel.lightEffectColorSelected = index
                        return
                    }
                    print("removing light effect color selected to \(index)")
                    if index == viewModel.lightEffectColor.count - 1 {
                        viewModel.lightEffectColorSelected = index - 1
                    }
                    viewModel.lightEffectColor.remove(at: index)
                } else {
                    print("setting light effect color selected to \(index)")
                    viewModel.lightEffectColorSelected = index
                }
            }
    }
    
    @ViewBuilder func lightEffectPicker(name: Int) -> some View {
        Image("\(name)effect")
            .resizable()
            .frame(width: 60,height: 60)
            .onTapGesture {
                print("setting light effect style to \(name-1)")
                viewModel.lightEffectStyle = name-1
            }
            .brightness(viewModel.lightEffectStyle == name-1 ? -0.5 : 0)
            .overlay() {
                if viewModel.lightEffectStyle == name-1 {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .frame(height: 40)
                        .frame(alignment: .center)
                }
            }
            .cornerRadius(5)
    }
    
    @ViewBuilder func addLightEffectColorButton() -> some View {
        Image(systemName: "plus.circle.fill")
            .resizable()
            .frame(width: 40,height: 40)
            .onTapGesture {
                viewModel.lightEffectColor.append(.blue)
                viewModel.lightEffectColorSelected = viewModel.lightEffectColor.count-1
            }
            .cornerRadius(5)
    }
    
    @ViewBuilder var lightEffect: some View {
        VStack(spacing: elementSpacing) {
            HStack {
                Button(action: {
                    viewModel.currentScreen = .home
                }, label: {
                    Image(systemName: "chevron.backward")
                })
                Text("Lighting Effects")
                    .bold()
                Image(systemName: "rainbow")
                    .renderingMode(.original)
                    .font(.system(size: 24))
                    .frame(height: 40)
            }
            CompactSlider(
                value: $viewModel.brightness,
                in: 5...100,
                step: 1
            ) {
                Text("Brightness")
                Spacer()
                Text(String(format: "%.0f%%", viewModel.brightness))
            }
            .frame(height: 24)
            .onChange(of: viewModel.brightness) {
                viewModel.setBrightness()
            }
            
            HStack {
                ForEach(Array(viewModel.lightEffectColor.enumerated()), id: \.offset) { index, color in
                    lightColor(index: index)
                }
                if viewModel.lightEffectColor.count < 7 {
                    addLightEffectColorButton()
                }
            }
            
            ColorPickerRing(color: $viewModel.lightEffectColor[viewModel.lightEffectColorSelected], strokeWidth: 30)
                        .frame(width: 200, height: 200, alignment: .center)
                        .onChange(of: viewModel.lightEffectColor) {
                            viewModel.setLightEffect()
                        }
            HStack {
                lightEffectPicker(name: 1)
                lightEffectPicker(name: 2)
                lightEffectPicker(name: 3)
                lightEffectPicker(name: 4)
            }
            HStack {
                lightEffectPicker(name: 5)
                lightEffectPicker(name: 6)
                lightEffectPicker(name: 7)
            }
            .onChange(of: viewModel.lightEffectStyle) {
                viewModel.setLightEffect()
            }
        }
    }
    
    @ViewBuilder func imagePicker(name: Int) -> some View {
        Image("\(name)")
            .resizable()
            .frame(width: 60,height: 60)
            .onTapGesture {
                print("setting clock style to \(name-1)")
                viewModel.clockStyle = name-1
            }
            .brightness(viewModel.clockStyle == name-1 ? -0.5 : 0)
            .overlay() {
                if viewModel.clockStyle == name-1 {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .frame(height: 40)
                        .frame(alignment: .center)
                }
            }
            .cornerRadius(5)
    }
    
    @ViewBuilder var clock: some View {
        VStack(spacing: elementSpacing) {
            HStack {
                Button(action: {
                    viewModel.currentScreen = .home
                }, label: {
                    Image(systemName: "chevron.backward")
                })
                Text("Clock")
                    .bold()
                Image(systemName: "clock.fill")
                    .font(.system(size: 24))
                    .frame(height: 40)
            }
            CompactSlider(
                value: $viewModel.brightness,
                in: 5...100,
                step: 1
            ) {
                Text("Brightness")
                Spacer()
                Text(String(format: "%.0f%%", viewModel.brightness))
            }
            .frame(height: 24)
            .onChange(of: viewModel.brightness) {
                viewModel.setBrightness()
            }
            ColorPickerRing(color: $viewModel.color, strokeWidth: 30)
                        .frame(width: 200, height: 200, alignment: .center)
                        .onChange(of: viewModel.color) {
                            viewModel.setClock()
                        }
            HStack {
                imagePicker(name: 1)
                imagePicker(name: 2)
                imagePicker(name: 3)
                imagePicker(name: 4)
            }
            HStack {
                imagePicker(name: 5)
                imagePicker(name: 6)
                imagePicker(name: 7)
                imagePicker(name: 8)
            }
            .onChange(of: viewModel.clockStyle) {
                viewModel.setClock()
            }
            Toggle(isOn: $viewModel.visibleDate) {
                Text("Display date")
            }
            .onChange(of: viewModel.visibleDate) {
                viewModel.setClock()
            }
            Toggle(isOn: $viewModel.hour24) {
                Text("24 Hours")
            }
            .onChange(of: viewModel.hour24) {
                viewModel.setClock()
            }
        }
    }
    
    @ViewBuilder var chronograph: some View {
        VStack(spacing: elementSpacing) {
            HStack {
                Button(action: {
                    viewModel.currentScreen = .home
                }, label: {
                    Image(systemName: "chevron.backward")
                })
                Text("Stopwatch")
                    .bold()
                Image(systemName: "stopwatch.fill")
                    .font(.system(size: 24))
                    .frame(height: 40)
            }
            HStack {
                switch viewModel.chronographMode {
                case .reset:
                    Button("Start") {
                        viewModel.chronographMode = .start
                        viewModel.setChronograph()
                    }
                case .start:
                    Button("Pause") {
                        viewModel.chronographMode = .pause
                        viewModel.setChronograph()
                    }
                case .pause:
                    Button("Unpause") {
                        viewModel.chronographMode = .unpause
                        viewModel.setChronograph()
                    }
                    Button("Reset") {
                        viewModel.chronographMode = .reset
                        viewModel.setChronograph()
                        viewModel.setClock()
                    }
                case .unpause:
                    Button("Pause") {
                        viewModel.chronographMode = .pause
                        viewModel.setChronograph()
                    }
                }
            }
        }
    }
    
    @ViewBuilder var countdown: some View {
        VStack(spacing: elementSpacing) {
            HStack {
                Button(action: {
                    viewModel.currentScreen = .home
                }, label: {
                    Image(systemName: "chevron.backward")
                })
                Text("Timer")
                    .bold()
                Image(systemName: "timer.circle.fill")
                    .font(.system(size: 24))
                    .frame(height: 40)
            }
            CompactSlider(
                value: $viewModel.minutes,
                in: 0...90,
                step: 1.0
            ) {
                Text(String(format: "%.0f Minutes", viewModel.minutes))
            }
            .frame(height: 24)
            CompactSlider(
                value: $viewModel.seconds,
                in: 0...59,
                step: 1.0
            ) {
                Text(String(format: "%.0f Seconds", viewModel.seconds))
            }
            .frame(height: 24)
            HStack {
                switch viewModel.countdownMode {
                case .disable:
                    Button("Start") {
                        viewModel.countdownMode = .start
                        viewModel.setCountdown()
                    }
                case .start:
                    Button("Pause") {
                        viewModel.countdownMode = .pause
                        viewModel.setCountdown()
                    }
                case .pause:
                    Button("Unpause") {
                        viewModel.countdownMode = .unpause
                        viewModel.setCountdown()
                    }
                    Button("Reset") {
                        viewModel.countdownMode = .disable
                        viewModel.setCountdown()
                    }
                case .unpause:
                    Button("Pause") {
                        viewModel.countdownMode = .pause
                        viewModel.setCountdown()
                    }
                }
            }
        }
    }
    
    @ViewBuilder var eco: some View {
        VStack(spacing: elementSpacing) {
            HStack {
                Button(action: {
                    viewModel.currentScreen = .home
                }, label: {
                    Image(systemName: "chevron.backward")
                })
                Text("Eco")
                    .bold()
                Image(systemName: "powersleep")
                    .font(.system(size: 24))
                    .frame(height: 40)
            }
            Button("Set Eco Schedule On") {
                viewModel.setEco()
            }
            Button("Cancel Eco") {
                viewModel.cancelEco()
            }
            DatePicker("Start Time", selection: $viewModel.startUpDate, displayedComponents: .hourAndMinute)
            DatePicker("End Time", selection: $viewModel.endDate, displayedComponents: .hourAndMinute)
            CompactSlider(
                value: $viewModel.ecoBrightness,
                in: 5...100,
                step: 1.0
            ) {
                Text("Eco Brightness")
                Spacer()
                Text(String(format: "%.0f%%", viewModel.ecoBrightness))
            }
            .frame(height: 24)
        }
    }
    
    @ViewBuilder var musicIntegration: some View {
        VStack(spacing: elementSpacing) {
            HStack {
                Button(action: {
                    viewModel.currentScreen = .home
                }, label: {
                    Image(systemName: "chevron.backward")
                })
                Text("Music Integration")
                    .bold()
                Image(systemName: "music.quarternote.3")
                    .font(.system(size: 24))
                    .frame(height: 40)
            }
            HStack {
                Text("Clock color update from Lyric Fever")
                Text("Pixelated album art from Spotify / Apple Music")
                Text("Light Effects from Spotify / Apple Music colors")
            }
        }
    }
    
    @ViewBuilder func sampleButton(_ buttonType: ViewModel.possibleScreens, _ buttonText: String, _ imageText: String) -> some View {
        Button {
            viewModel.currentScreen = buttonType
        } label: {
            VStack(spacing: 5) {
                Image(systemName: imageText)
//                    .renderingMode(.original)
                Text(buttonText)
                    .font(.system(size: 12, weight: .semibold))
                    .fixedSize()
//                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.foreground)
            .frame(minWidth: 100, maxWidth: .infinity)
            .padding(.vertical, 16)
//            .padding(.horizontal, 20)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 10))
                    .shadow(radius: 5)
            )
//            .frame(idealWidth: 90, maxWidth: 90, minHeight: 100, idealHeight: 100, maxHeight: 100)
        }
//        .frame(width: 90,height: 50, maxWidth: 90)
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder var ConnectedView: some View {
        VStack(spacing: groupSpacing) {
            HStack(spacing: 15) {
                sampleButton(.clock, "Clock", "clock.fill")
                sampleButton(.lightEffect, "Light Effect", "rainbow")
                sampleButton(.fullscreenColor, "Screen Color", "display")
                
            }
            HStack(spacing: 15) {
                sampleButton(.stopwatch, "Stopwatch", "stopwatch.fill")
                sampleButton(.timer, "Timer", "timer.circle.fill")
                sampleButton(.text, "Text", "text.bubble.fill")
            }
            HStack(spacing: 15) {
                sampleButton(.gifImage, "Gif Image", "photo.stack")
                sampleButton(.image, "Image", "photo.fill")
                sampleButton(.eco, "Eco", "moon")
            }
//            Button("Screen Color") {
//                viewModel.currentScreen = .fullscreenColor
//            }
//            Button("Gif Image") {
//                viewModel.currentScreen = .gifImage
//            }
//            Button("Image") {
//                viewModel.currentScreen = .image
//            }
//            Button("Text") {
//                viewModel.currentScreen = .text
//            }
//            Button("Light Effect") {
//                viewModel.currentScreen = .lightEffect
//            }
//            Button("Clock") {
//                viewModel.currentScreen = .clock
//            }
//            Button("Stopwatch") {
//                viewModel.currentScreen = .stopwatch
//            }
//            Button("Timer") {
//                viewModel.currentScreen = .timer
//            }
//            Button("Eco") {
//                viewModel.currentScreen = .eco
//            }
            HStack {
                Button("Display Settings") {
                    viewModel.currentScreen = .common
                }
                Button("Music Integration") {
                    viewModel.currentScreen = .musicIntegration
                }
            }
            HStack {
                Button("Disconnect Device") {
                    viewModel.disconnect()
                }
                #if os(macOS)
                Button("Quit") {
                    UserDefaults.standard.setValue(viewModel.color.redComponent*255, forKey: "red")
                    UserDefaults.standard.setValue(viewModel.color.greenComponent*255, forKey: "green")
                    UserDefaults.standard.setValue(viewModel.color.blueComponent*255, forKey: "blue")
                    for (index,color) in viewModel.lightEffectColor.enumerated() {
                        UserDefaults.standard.setValue(color.redComponent*255, forKey: "redLightEffect\(index)")
                        UserDefaults.standard.setValue(color.greenComponent*255, forKey: "greenLightEffect\(index)")
                        UserDefaults.standard.setValue(color.blueComponent*255, forKey: "blueLightEffect\(index)")
                    }
                    UserDefaults.standard.setValue(viewModel.lightEffectColor.count, forKey: "lightEffectCount")
                    NSApplication.shared.terminate(nil)
                }
                #endif
            }
        }
        .background(.clear)
    }
    
    var body: some View {
        VStack(spacing: groupSpacing) {
            switch viewModel.currentScreen {
                case .common:
                    common
                case .fullscreenColor:
                    fullscreenColor
                case .gifImage:
                    gifImage
                case .image:
                    image
                case .text:
                    text
                case .lightEffect:
                    lightEffect
                case .clock:
                    clock
                case .stopwatch:
                    chronograph
                case .timer:
                    countdown
                case .eco:
                    eco
                case .musicIntegration:
                    musicIntegration
                case .home:
                    HStack {
                        Text(viewModel.statusDescription)
                            .bold()
                        Image(systemName: viewModel.labelIconSystemImage)
                            .font(.system(size: 24))
                            .frame(height: 40)
                    }
                    if viewModel.deviceStatus == .on {
                        HStack {
                            Button("Search Again") {
                                viewModel.searchAgain()
                            }
                            #if os(macOS)
                            Button("Quit") {
                                UserDefaults.standard.setValue(viewModel.color.redComponent*255, forKey: "red")
                                UserDefaults.standard.setValue(viewModel.color.greenComponent*255, forKey: "green")
                                UserDefaults.standard.setValue(viewModel.color.blueComponent*255, forKey: "blue")
                                NSApplication.shared.terminate(nil)
                            }
                            #endif
                        }
                    }
                    if viewModel.deviceStatus == .connected {
                        ConnectedView
                    }
            }
        }
        .padding(.horizontal, 30)
        .padding(10)
//        .onReceive(DistributedNotificationCenter.default().publisher(for: Notification.Name("LyricFeverColorUpdate")), perform: { notification in
//            print("RECEIVED NOTIFCIATION")
//            if let jsonString = notification.object as? String,
//                    let jsonData = jsonString.data(using: .utf8) {
//                     // Convert JSON string to dictionary
//                     if let colorData = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: CGFloat],
//                        let red = colorData["red"],
//                        let green = colorData["green"],
//                        let blue = colorData["blue"] {
//                         // Use the RGB values
////                         print("Received RGB values: red=\(red), green=\(green), blue=\(blue)")
////                         ViewModel.shared.red = blue > red ? red * 255 : min(red * 450, 255)
////                         ViewModel.shared.green = blue > green ? green * 255 : min(green * 260, 255)
////                         ViewModel.shared.blue = blue * 255
////                         ViewModel.shared.setClock()
//                     } else {
//                         print("Failed to decode color data")
//                     }
//                 } else {
//                     print("Notification object is not a valid JSON string")
//                 }
//        })
    }
}
