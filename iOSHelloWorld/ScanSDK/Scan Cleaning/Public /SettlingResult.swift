//
//  SettlingResult.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-11-29.
//

import Foundation

/**
 An enum to represent the setting status of the mesh setting.
 
 - stable: The settling is stable, therefore successful.
 - unstable: The stelling is unstable, therefore unsuccessful.
 - rotationLimitExceeded: The rotation angle could not be fully attained because of the rotation limit.
 */
public enum SettlingStatus: Int32 {
    case stable = 0
    case unstable = 1
    case rotationLimitExceeded = 2
}
