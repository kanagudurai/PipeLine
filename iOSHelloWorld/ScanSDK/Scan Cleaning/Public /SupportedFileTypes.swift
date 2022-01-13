//
//  SupportedFileTypes.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-11-29.
//

import Foundation

/**
 An enum to represent the supported file types for the mesh cleaning.
 
 - ply: Polygon.
 - obj: Wavefront Object.
 */
public enum SupportedFileTypes: String, CaseIterable {
    case ply
    case obj
    
    /// The file extension related to the file type.
    var fileExtension: String {
        rawValue
    }
    
    /**
     Returns a Boolean value that indicates whether the file extension is supported for reading, cleaning and exporting the specified file extension.
     - parameters:
      - fileExtension: The filename extension identifying an asset file format.
    - returns:  `true` if the  file extension is supported for reading, cleaning and exporting asset data from files with the specified extension; otherwise, `false`.
     */
    static func isFileExtensionSupported(_ fileExtension: String) -> Bool {
        SupportedFileTypes(rawValue: fileExtension) != nil
    }
}
