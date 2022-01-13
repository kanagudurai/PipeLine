//
//  NodeCleaner.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-12-01.
//

import Foundation
import SceneKit
import Combine

struct NodeCleaner {
    
    var node: SCNNode
    
    func publisher() -> AnyPublisher<SCNNode, Error> {
        let _ = try? FileManager
            .default
            .removeItem(
                at: FileManager.beforeCleaningTempMeshURL
            )
        let _ = try? FileManager
            .default
            .removeItem(
                at: FileManager.afterCleaningTempMeshURL
            )
        return export()
            .flatMap {
                cleanerPublisher()
            }
            .flatMap { _ in
                loadAsset()
            }
            .eraseToAnyPublisher()
    }
    
    private func cleanerPublisher() -> AnyPublisher<Void, Error> {
        FootMeshCleaner(
            fileURL: FileManager.beforeCleaningTempMeshURL,
            saveURL: FileManager.afterCleaningTempMeshURL
        ).publisher()
    }
    
    private func export() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            DispatchQueue
                .global(qos: .utility)
                .async {
                    let scene = SCNScene()
                    scene
                        .rootNode
                        .addChildNode(
                            node.clone()
                        )
                    scene
                        .write(
                            to: FileManager.beforeCleaningTempMeshURL,
                            options: nil,
                            delegate: nil
                        ) { progress, error, stop in
                            if let saveError = error {
                                promise(
                                    .failure(
                                        saveError
                                    )
                                )
                            }
                            else if Int(progress) == 1 {
                                promise(.success(Void()))
                            }
                        }
                }
        }
        .eraseToAnyPublisher()
    }
    
    private func loadAsset() -> AnyPublisher<SCNNode, Error> {
        Future<SCNNode, Error> { promise in
            let asset = MDLAsset(url: FileManager.afterCleaningTempMeshURL)
            let scene = SCNScene(mdlAsset: asset)
            guard let node = scene.rootNode.childNodes.first else {
                promise(.failure(MeshCleaningError.missingRootNode))
                return
            }
            promise(.success(node))
        }
        .eraseToAnyPublisher()
    }
}
