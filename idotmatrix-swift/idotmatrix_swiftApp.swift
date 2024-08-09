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
        
        var body: some View {
            Group {
                Text(viewModel.statusDescription)
                if viewModel.deviceStatus == .on {
                    Button("Search Again") {
                        viewModel.searchAgain()
                    }
                }
                if viewModel.deviceStatus == .connected {
                    Button("Disconnect") {
                        viewModel.disconnect()
                    }
                }
                Slider(
                    value: $viewModel.brightness,
                    in: 5...100,
                    onEditingChanged: { editing in
                        if !editing {
                            viewModel.setBrightness()
                        }
                    }
                )
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
