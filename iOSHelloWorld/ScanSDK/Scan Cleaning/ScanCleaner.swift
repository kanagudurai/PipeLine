//
//  ScanCleaner.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-09-06.
//

import Foundation
import SceneKit
import Combine

struct ScanCleaner: GeometrySettler, GeometrySlicer, GeometryCleaner, GeometryTransformer {
    
    var scan: SCNNode

    func publisher() -> AnyPublisher<ScanCleanResult, Never> {
        return slicePromise(
            geometry: scan.geometry!,
            boundingBox:
                CleanerBoundBox(
                    box:
                        (min:
                            SCNVector3(
                                x: -100,
                                y: -250,
                                z: -400
                            ),
                         max:
                            SCNVector3(
                                x: 100,
                                y: 250,
                                z: 400
                            )
                        )
                ),
            translation: SCNVector3Zero,
            transform: scan.transform
        )
            .flatMap { cleanPromise(geometry: $0) }
            .flatMap { slicePromise2(geometry: $0) }
            .flatMap { cleanPromise(geometry: $0) }
            .flatMap { settleProvise(geometry: $0, transform: SCNMatrix4Identity) }
            .flatMap { newNode(result: $0) }
            .eraseToAnyPublisher()
    }
    
    private func slicePromise2(geometry: SCNGeometry) -> Future<SCNGeometry, Never> {
        let newNode = SCNNode(geometry: geometry)
        let boundingBox = CleanerBoundBox(box: newNode.boundingBox)
        return slicePromise(
            geometry: newNode.geometry!,
            boundingBox:
                CleanerBoundBox(
                    box:
                        (min:
                            SCNVector3(
                                x: -100,
                                y: -400,
                                z: boundingBox.max.z - 100
                            ),
                         max:
                            SCNVector3(
                                x: 100,
                                y: 400,
                                z: boundingBox.max.z
                            )
                        )
                ),
            translation:SCNVector3(),
            transform: SCNMatrix4Identity
        )
    }
    
    private func newNode(geometry: SCNGeometry) -> Future<SCNNode, Never> {
        Future { promise in
            let newNode = SCNNode(geometry: geometry)
            promise(.success(newNode))
        }
    }
    
    private func newNode(result: SettleResult) -> Future<ScanCleanResult, Never> {
        Future { promise in
            let newNode = SCNNode(
                geometry: result.goemetry
            )
            newNode.transform = SCNMatrix4Translate(
                newNode.transform,
                -newNode.boundingSphere.center.x,
                -newNode.boundingSphere.center.y,
                0
            )
            promise(
                .success(
                    ScanCleanResult(
                        settleResult: result,
                        node: newNode
                    )
                )
            )
        }
    }
    
}

struct SettleResult {
    var transformationMatrix: SCNMatrix4
    var goemetry: SCNGeometry
    var rotationAngle: Float
    var status: SettlingStatus
}


struct ScanCleanResult {
    
    var settleResult: SettleResult
    var node: SCNNode
    
}



