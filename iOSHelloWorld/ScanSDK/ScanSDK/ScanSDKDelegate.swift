//
//  ScanSDKDelegate.swift
//  ScanSDK
//
//  Created by Benjamin Comeau on 2021-10-21.
//  Copyright © 2021 Podform3D. All rights reserved.
//

import Foundation

// Implement delegate to receive ScanSessionManager updates
public protocol ScanSDKDelegate: AnyObject {
    func scanStatusDidChange(scanStatus: ScanStatus)
}

public enum ScanStatus {
    case stopped
    case inProgress
    case complete
    case canceled
}

public enum FileType {
    case OBJ
    case PLY
}
