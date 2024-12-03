//
//  DeviceStatusEnum.swift
//  Dot Matrix
//
//  Created by Avi Wadhwa on 2024-12-01.
//

extension ViewModel {
    enum DeviceStatusEnum: Equatable {
        case on
        case searching
        case connected
        case error(String) // Associated value to store the error message
    }
    
    var statusDescription: String {
        switch deviceStatus {
        case .on:
            return "Disconnected"
        case .searching:
            return "Searching.."
        case .connected:
            guard let name = device?.name else {
                return "Fail"
            }
            return "Connected to \(name)"
        case .error(let errorMessage):
            return "Error: \(errorMessage)"
        }
    }
    
    var labelIconSystemImage: String {
        switch deviceStatus {
        case .on:
            "xmark.icloud.fill"
        case .searching:
            "magnifyingglass"
        case .connected:
            "checkmark.icloud.fill"
        case .error(_):
            "exclamationmark.icloud.fill"
        }
    }
}
