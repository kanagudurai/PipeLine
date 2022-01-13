//
//  Settler.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-08-17.
//

import SceneKit
import Combine
protocol GeometrySettler {
    
    func settleProvise(geometry: SCNGeometry, transform: SCNMatrix4) -> Future<SettleResult, Never>
    func settle(geometry: SCNGeometry, transform: SCNMatrix4) -> SettleResult
}

extension GeometrySettler {
    
    func settleProvise(geometry: SCNGeometry, transform: SCNMatrix4) -> Future<SettleResult, Never> {
        Future { promise in
            DispatchQueue
                .global(qos: .utility)
                .async {
                    let matrix = settle(
                        geometry: geometry,
                        transform: transform
                    )
                    promise(.success(matrix))
                }
        }
    }
    
}

#if targetEnvironment(simulator)
extension GeometrySettler {
    
    func settle(geometry: SCNGeometry, transform: SCNMatrix4) -> SettleResult {
        let result = SettleResult(
            transformationMatrix: transform,
            goemetry: geometry,
            rotationAngle: 0,
            status: SettlingStatus(rawValue: status) ?? .unstable
        )
        return result
    }

}
#else
extension GeometrySettler {
    
    func settle(geometry: SCNGeometry, transform: SCNMatrix4) -> SettleResult {
//        return SettleResult(
//            transformationMatrix: transform,
//            goemetry: geometry,
//            rotationAngle: 0,
//            status: .stable
//        )
        let geometryInfo = geometry.info
        let vertices = geometryInfo
            .vertices
        let verticesArray =
            vertices
            .flatMap { $0.arrayReprensentation }
        let numberOfVertices = vertices.count
        let triangles = geometryInfo
            .triangles
        let trianglesArray =
            triangles
            .flatMap { $0.arrayReprensentation }
        let numberOfTriangles = triangles.count
        var initialTransform = transform.columnmMajorOrderArrayRepresentation
        let gravityDirectionX: Float = 0
        let gravityDirectionY: Float = 0
        let gravityDirectionZ: Float = 1
        let maxIterations: Int32 = 100
        var resultMatrix = SCNMatrix4Identity.columnmMajorOrderArrayRepresentation
        let maxRotationAngle: Float = 1.57
        var rotationAngle: Float = 0
        let status = leoSettleObject(verticesArray,
                        Int32(numberOfVertices),
                        trianglesArray,
                        Int32(numberOfTriangles),
                        &initialTransform,
                        gravityDirectionX,
                        gravityDirectionY,
                        gravityDirectionZ,
                        maxIterations,
                        maxRotationAngle,
                        &resultMatrix,
                        &rotationAngle)
        let transformationMatrix = SCNMatrix4(columnmMajorOrderArrayRepresentation: resultMatrix)
        let newGeometry = geometry
            .applying(transform: transformationMatrix)
        let result = SettleResult(
            transformationMatrix: transformationMatrix,
            goemetry: newGeometry,
            rotationAngle: rotationAngle,
            status: SettlingStatus(rawValue: status) ?? .unstable
        )
        return result
    }
    
}

#endif


extension SCNMatrix4 {
    
    init(columnmMajorOrderArrayRepresentation: [Float]) {
        self.init()
        m11 = columnmMajorOrderArrayRepresentation[0]
        m21 = columnmMajorOrderArrayRepresentation[1]
        m31 = columnmMajorOrderArrayRepresentation[2]
        m41 = columnmMajorOrderArrayRepresentation[3]
        m12 = columnmMajorOrderArrayRepresentation[4]
        m22 = columnmMajorOrderArrayRepresentation[5]
        m32 = columnmMajorOrderArrayRepresentation[6]
        m42 = columnmMajorOrderArrayRepresentation[7]
        m13 = columnmMajorOrderArrayRepresentation[8]
        m23 = columnmMajorOrderArrayRepresentation[9]
        m33 = columnmMajorOrderArrayRepresentation[10]
        m43 = columnmMajorOrderArrayRepresentation[11]
        m14 = columnmMajorOrderArrayRepresentation[12]
        m24 = columnmMajorOrderArrayRepresentation[13]
        m34 = columnmMajorOrderArrayRepresentation[14]
        m44 = columnmMajorOrderArrayRepresentation[15]
    }
    
    var columnmMajorOrderArrayRepresentation: [Float] {
        [m11, m21, m31, m41,
         m12, m22, m32, m42,
         m13, m23, m33, m43,
         m14, m24, m34, m44]
    }
}

extension SCNGeometry.Vertex {
    var arrayReprensentation: [Float] {
        coordinate.arrayReprensentation
    }
}

extension SCNVector3 {
    
    var arrayReprensentation: [Float] {
        [x, y , z]
    }
    
}

extension SCNGeometry.Triangle {
    
    var arrayReprensentation: [Int32] {
        [Int32(v0.index),
         Int32(v1.index),
         Int32(v2.index)]
    }
    
}
