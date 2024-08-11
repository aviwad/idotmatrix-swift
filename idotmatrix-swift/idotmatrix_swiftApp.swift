//
//  idotmatrix_swiftApp.swift
//  idotmatrix-swift
//
//  Created by Avi Wadhwa on 2024-08-08.
//

import SwiftUI
import CompactSlider

@main
struct idotmatrix_swiftApp: App {
    @State var viewModel = ViewModel()
    
    struct Content: View {
        @Binding var viewModel: ViewModel
        let elementSpacing = 8.0
        let groupSpacing = 9.0
        
        @ViewBuilder var common: some View {
            VStack(spacing: elementSpacing) {
                HStack {
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
                    Text("Fullscreen Color")
                        .bold()
                    Rectangle()
                        .fill(Color(red: viewModel.red/255, green: viewModel.green/255, blue: viewModel.blue/255))
                        .frame(width: 25, height: 25)
                        .cornerRadius(5)
                        .padding(.vertical, 7.5)
                        .padding(.trailing, 15)
                }
                CompactSlider(
                    value: $viewModel.red,
                    in: 0...255,
                    step: 1.0
                ) {
                    Text("Red")
                    Spacer()
                    Rectangle()
                        .fill(Color(red: viewModel.red/255, green: 0, blue: 0))
                        .frame(width: 25)
                        .cornerRadius(5)
                }
                .frame(height: 24)
                .onChange(of: viewModel.red) {
                    viewModel.setFullScreenColor()
                }
                CompactSlider(
                    value: $viewModel.green,
                    in: 0...255,
                    step: 1.0
                ) {
                    Text("Green")
                    Spacer()
                    Rectangle()
                        .fill(Color(red: 0, green: viewModel.green/255, blue: 0))
                        .frame(width: 25)
                        .cornerRadius(5)
                }
                .frame(height: 24)
                .onChange(of: viewModel.green) {
                    viewModel.setFullScreenColor()
                }
                CompactSlider(
                    value: $viewModel.blue,
                    in: 0...255,
                    step: 1.0
                ) {
                    Text("Blue")
                    Spacer()
                    Rectangle()
                        .fill(Color(red: 0, green: 0, blue: viewModel.blue/255))
                        .frame(width: 25)
                        .cornerRadius(5)
                }
                .frame(height: 24)
                .onChange(of: viewModel.blue) {
                    viewModel.setFullScreenColor()
                }
            }
        }
        
        @ViewBuilder var clock: some View {
            VStack(spacing: elementSpacing) {
                HStack {
                    Text("Clock")
                        .bold()
                    Image(systemName: "clock.fill")
                        .font(.system(size: 24))
                        .frame(height: 40)
                }
                Picker("Clock Style?", selection: $viewModel.clockStyle) {
                    Text("First").tag(0)
                    Text("Second").tag(1)
                    Text("Third").tag(2)
                    Text("Fourth").tag(3)
                    Text("Fifth").tag(4)
                    Text("Sixth").tag(5)
                    Text("Seventh").tag(6)
                    Text("Eighth").tag(7)
                }
                .labelsHidden()
                .pickerStyle(.segmented)
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
        
        @ViewBuilder var connected: some View {
            VStack(spacing: groupSpacing) {
                HStack {
                    Button("Disconnect Device") {
                        viewModel.disconnect()
                    }
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                }
                common
                fullscreenColor
                clock
                chronograph
                countdown
                eco
            }
        }
        
        var body: some View {
            VStack(spacing: groupSpacing) {
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
                        Button("Quit") {
                            NSApplication.shared.terminate(nil)
                        }
                    }
                }
                if viewModel.deviceStatus == .connected {
                    connected
                }
            }
            .padding(10)
        }
    }
    var body: some Scene {
        MenuBarExtra(content: {
            Content(viewModel: $viewModel)
//                .onChange(of: viewModel.device) {
//                    Task {
//                        viewModel.connectToDevice()
//                    }
//                }
        }, label: {
            Image(systemName: viewModel.labelIconSystemImage)
        }).menuBarExtraStyle(.window)
    }
}
