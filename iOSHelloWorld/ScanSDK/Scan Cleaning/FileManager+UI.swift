//
//  FileManager+UI.swift
//  DevSetup
//
//  Created by Kandi Sridhar Reddy on 17/12/21.
//

import Foundation


extension FileManager {
    
    static var beforeCleaningTempMeshURL: URL {
        let directory = FileManager
                        .default
                        .urls(for: .documentDirectory,
                                 in: .userDomainMask)
                        .first!
        
        return directory
                .appendingPathComponent("beforeClean.ply")
        
        
    }
    
    static var afterCleaningTempMeshURL: URL {
        let directory = FileManager
                        .default
                        .urls(for: .documentDirectory,
                                 in: .userDomainMask)
                        .first!
        
        return directory
                .appendingPathComponent("afterClean.ply")
        
    }
}
