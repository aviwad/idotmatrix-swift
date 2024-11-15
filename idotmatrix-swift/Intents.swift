//
//  Intents.swift
//  idotmatrix-swift
//
//  Created by Avi Wadhwa on 2024-08-10.
//

import Foundation
import AppIntents

struct StartStopwatch: AppIntent {
    static var title: LocalizedStringResource = "Start Stopwatch"
    static var description = IntentDescription("Starts the stopwatch.")
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        ViewModel.shared.chronographMode = .start
        ViewModel.shared.setChronograph()
        return .result()
    }
}

struct PauseStopwatch: AppIntent {
    static var title: LocalizedStringResource = "Pause Stopwatch"
    static var description = IntentDescription("Pauses the stopwatch.")
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        ViewModel.shared.chronographMode = .pause
        ViewModel.shared.setChronograph()
        return .result()
    }
}

struct UnpauseStopwatch: AppIntent {
    static var title: LocalizedStringResource = "Unpause Stopwatch"
    static var description = IntentDescription("Unpauses the stopwatch.")
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        ViewModel.shared.chronographMode = .unpause
        ViewModel.shared.setChronograph()
        return .result()
    }
}


struct StopStopwatch: AppIntent {
    static var title: LocalizedStringResource = "Stop Stopwatch"
    static var description = IntentDescription("Stops the stopwatch.")
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        ViewModel.shared.chronographMode = .reset
        ViewModel.shared.setChronograph()
        ViewModel.shared.setClock()
        return .result()
    }
}
