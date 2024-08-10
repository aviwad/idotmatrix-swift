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
                Text("Fullscreen Color")
                HStack {
                    Text("Red")
                        .frame(width: 50)
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
        
        @ViewBuilder var connected: some View {
            VStack(spacing: 10) {
                Button("Disconnect") {
                    viewModel.disconnect()
                }
                common
                fullscreenColor
                clock
                chronograph
            }
        }
        
        var body: some View {
            Group {
                Text(viewModel.statusDescription)
                if viewModel.deviceStatus == .on {
                    Button("Search Again") {
                        viewModel.searchAgain()
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
