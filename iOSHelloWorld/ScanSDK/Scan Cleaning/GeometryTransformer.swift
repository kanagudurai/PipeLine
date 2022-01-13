//
//  GeometryTransformer.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-11-23.
//

import SceneKit
import Combine

protocol GeometryTransformer {
    
    func applying(_ transform: SCNMatrix4, on geometry: SCNGeometry) -> Future<SCNGeometry, Never>
}

extension GeometryTransformer {
    
    func applying(_ transform: SCNMatrix4, on geometry: SCNGeometry) -> Future<SCNGeometry, Never> {
        Future { promise in
            DispatchQueue.global(qos: .utility).async {
                let newGeometry = geometry.applying(transform: transform)
                promise(.success(newGeometry))
            }
        }
    }
    
}
