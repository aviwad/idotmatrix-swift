//
//  idotmatrix_swiftApp.swift
//  idotmatrix-swift
//
//  Created by Avi Wadhwa on 2024-08-08.
//

import SwiftUI
import SwiftBluetooth

@main
struct idotmatrix_swiftApp: App {
    @State var viewModel = ViewModel()
    
    struct Content: View {
        @Binding var viewModel: ViewModel
        
        @ViewBuilder var common: some View {
            VStack(spacing: 5) {
                Text("Common Screen Behaviour")
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
                
                Slider(
                    value: $viewModel.brightness,
                    in: 5...100,
                    step: 1.0
                )
                .onChange(of: viewModel.brightness) {
                    viewModel.setBrightness()
                }
            }
        }
        
        @ViewBuilder var fullscreenColor: some View {
            VStack(spacing: 5) {
                HStack {
                    Text("Fullscreen Color")
                    Rectangle()
                        .fill(Color(red: viewModel.red/255, green: viewModel.green/255, blue: viewModel.blue/255))
                        .frame(width: 20)
                        .cornerRadius(5)
                }
                HStack {
                    Text("Red")
                        .frame(width: 50)
                    Rectangle()
                        .fill(Color(red: viewModel.red/255, green: 0, blue: 0))
                        .frame(width: 20)
                        .cornerRadius(5)
                    Slider(
                        value: $viewModel.red,
                        in: 0...255,
                        step: 1.0
                    )
                    .onChange(of: viewModel.red) {
                        viewModel.setFullScreenColor()
                    }
                }
                HStack {
                    Text("Green")
                        .frame(width: 50)
                    Rectangle()
                        .fill(Color(red: 0, green: viewModel.green/255, blue: 0))
                        .frame(width: 20)
                        .cornerRadius(5)
                    Slider(
                        value: $viewModel.green,
                        in: 0...255,
                        step: 1.0
                    )
                    .onChange(of: viewModel.green) {
                        viewModel.setFullScreenColor()
                    }
                }
                HStack {
                    Text("Blue")
                        .frame(width: 50)
                    Rectangle()
                        .fill(Color(red: 0, green: 0, blue: viewModel.blue/255))
                        .frame(width: 20)
                        .cornerRadius(5)
                    Slider(
                        value: $viewModel.blue,
                        in: 0...255,
                        step: 1.0
                    )
                    .onChange(of: viewModel.blue) {
                        viewModel.setFullScreenColor()
                    }
                }
            }
        }
        
        @ViewBuilder var clock: some View {
            VStack(spacing: 5) {
                Text("Clock")
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
            VStack(spacing: 5) {
                Text("Chronograph")
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
            VStack(spacing: 5) {
                Text("Countdown")
                HStack {
                    Text("\(UInt8(viewModel.minutes)) Minutes")
                        .frame(width: 80)
                    Slider(
                        value: $viewModel.minutes,
                        in: 0...90,
                        step: 1.0
                    )
                }
                HStack {
                    Text("\(UInt8(viewModel.seconds)) Seconds")
                        .frame(width: 80)
                    Slider(
                        value: $viewModel.seconds,
                        in: 0...59,
                        step: 1.0
                    )
                }
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
            VStack(spacing: 5) {
                Text("Eco")
                Button("Set Eco Schedule On") {
                    viewModel.setEco()
                }
                Button("Cancel Eco") {
                    viewModel.cancelEco()
                }
                DatePicker("Start Time", selection: $viewModel.startUpDate, displayedComponents: .hourAndMinute)
                DatePicker("End Time", selection: $viewModel.endDate, displayedComponents: .hourAndMinute)
                HStack {
                    Text("Eco Brightness")
                        .frame(width: 80)
                    Slider(
                        value: $viewModel.ecoBrightness,
                        in: 5...100,
                        step: 1.0
                    )
                }
            }
        }
        
        @ViewBuilder var connected: some View {
            VStack(spacing: 10) {
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
            Group {
                Text(viewModel.statusDescription)
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
