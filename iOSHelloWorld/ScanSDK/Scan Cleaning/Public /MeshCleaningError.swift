//
//  MeshCleaningError.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-11-29.
//

import Foundation

/**
 An enum to represent the setting status of the mesh setting
 
 - unsupportedFileTypes: The URLs path extensions are not supported. The unsupported urls will be contained in the `URLs` parameter.
 - missingRootNode: The root node of the loaded mesh is missing.
 - settlingFailed: The settling failed, see `status` for details.
 - savingError: Saving the mesh failed on the file system failed. See `error` for details.
 */
public enum MeshCleaningError: Error {
    case unsupportedFileTypes(URLs:[URL])
    case missingRootNode
    case settlingFailed(status: SettlingStatus)
    case savingError(error: Error)
}
