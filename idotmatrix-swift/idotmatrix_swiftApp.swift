//
//  idotmatrix_swiftApp.swift
//  idotmatrix-swift
//
//  Created by Avi Wadhwa on 2024-08-08.
//

import SwiftUI
import CompactSlider

#if os(macOS)
import FluidMenuBarExtra


class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarExtra: FluidMenuBarExtra?
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        self.menuBarExtra = FluidMenuBarExtra(title: "iDotMatrix Swift", systemImage: "photo.tv") {
            ContentWrapper()
//                .onReceive(DistributedNotificationCenter.default().publisher(for: Notification.Name("LyricFeverColorUpdate"))) { notif in 
//                    print("hi")
//                }
        }
    }
}
#endif



@main
struct idotmatrix_swiftApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        _EmptyScene()
//        MenuBarExtra(content: {
//            Content(viewModel: $viewModel)
//                .frame(width: 350, alignment: .top)
//        }, label: {
//            Image(systemName: viewModel.labelIconSystemImage)
//        }).menuBarExtraStyle(.window)
    }
    #endif
    
    #if os(iOS)
    
    var body: some Scene {
        WindowGroup {
            ContentWrapper()
        }
    }
    #endif
}
