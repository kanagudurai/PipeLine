//
//  ScanSaver.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-09-20.
//

import Foundation
import SceneKit
import Combine

protocol ScanSaver {
    
    func save(_ scan: SCNNode, at saveURL: URL)
    func savePromise(_ scan: SCNNode, at saveURL: URL) -> Future<URL, Error>
    
}

extension ScanSaver {
    
    func savePromise(_ scan: SCNNode, at saveURL: URL) -> Future<URL, Error> {
        Future { promise in
            let scene = SCNScene()
            let scanToSave = scan.clone()
            scanToSave.scale = SCNVector3(x: 1000, y: 1000, z: 1000)
            let center = scanToSave
                .boundingSphere
                .center
            scanToSave.pivot = SCNMatrix4MakeTranslation(
                center.x,
                center.y,
                center.z
            )
            scanToSave.eulerAngles.x = .pi
            scanToSave.eulerAngles.z = -.pi/2
            scene.rootNode.addChildNode(scanToSave)
            DispatchQueue.global(qos: .utility).async {
                scene
                    .write(to: saveURL,
                           options: nil,
                           delegate: nil) { progress, error, stop in
                    if let saveError = error {
                        promise(.failure(saveError))
                    }
                    else if Int(progress) == 1 {
                        promise(.success(saveURL))
                    }
                }
            }
        }
    }
    
    func save(_ scan: SCNNode, at saveURL: URL) {
        let scene = SCNScene()
        let scanToSave = scan.clone()
        scanToSave.scale = SCNVector3(x: 1000, y: 1000, z: 1000)
        let center = scanToSave
            .boundingSphere
            .center
        scanToSave.pivot = SCNMatrix4MakeTranslation(
            center.x,
            center.y,
            center.z
        )
        scanToSave.eulerAngles.x = .pi
        scanToSave.eulerAngles.z = -.pi/2
        scene.rootNode.addChildNode(scanToSave)
        scene
            .write(to: saveURL,
                   options: nil,
                   delegate: nil,
                   progressHandler: nil)
    }
    
    
}
