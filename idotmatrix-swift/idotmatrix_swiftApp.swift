//
//  idotmatrix_swiftApp.swift
//  idotmatrix-swift
//
//  Created by Avi Wadhwa on 2024-08-08.
//

import SwiftUI
import CompactSlider
import FluidMenuBarExtra

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarExtra: FluidMenuBarExtra?
    @StateObject var viewModel = ViewModel.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.menuBarExtra = FluidMenuBarExtra(title: "iDotMatrix Swift", systemImage: "photo.tv") {
            ContentWrapper()
        }
    }
}




@main
struct idotmatrix_swiftApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
//        MenuBarExtra(content: {
//            Content(viewModel: $viewModel)
//                .frame(width: 350, alignment: .top)
//        }, label: {
//            Image(systemName: viewModel.labelIconSystemImage)
//        }).menuBarExtraStyle(.window)
    }
}
