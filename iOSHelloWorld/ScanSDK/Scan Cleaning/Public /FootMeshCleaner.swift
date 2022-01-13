//
//  FootMeshCleaner.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-11-28.
//

import Foundation
import SwiftUI
import Combine
import ModelIO
import SceneKit

/**
 The `FootMeshCleaner` is responsible for cleaning a foot mesh.  The `fileURL` is the location to load the mesh from and the `saveURL` is where to save the clean mesh. To clean the mesh, call the `publisher()`. The publisher publishes `Void` when the task completes, or terminates if the task fails with an error.
 */
public struct FootMeshCleaner {
    
    /**
     The URL of the mesh asset located on the file system.
     - precondition: The `fileURL` must have path extensions which `SupportedFileTypes.isFileExtensionSupported(_)` return `true`.
    */
    public let fileURL: URL
    /**
     The URL of where to save the mesh asset on the file system.
     - precondition: The `saveURL` must have path extensions which `SupportedFileTypes.isFileExtensionSupported(_)` return `true`.
    */
    public let saveURL: URL
    
    /// The publisher publishes `Void` when the task completes, or terminates if the task fails with an error.
    public func publisher() -> AnyPublisher<Void, Error> {
        loadNode()
            .flatMap {
                ScanCleaner(scan: $0)
                    .publisher()
            }
            .flatMap {
                export(result: $0)
            }
            .eraseToAnyPublisher()
    }
    
    private func loadNode() -> AnyPublisher<SCNNode, Error> {
        Future<SCNNode, Error> { promise in
            DispatchQueue.global(qos: .utility).async {
                var invalidFileTypes: [URL] = []
                if SupportedFileTypes(rawValue: fileURL.pathExtension) == nil {
                    invalidFileTypes
                        .append(fileURL)
                }
                if SupportedFileTypes(rawValue: saveURL.pathExtension) == nil {
                    invalidFileTypes
                        .append(saveURL)
                }
                guard invalidFileTypes.isEmpty else {
                    promise(
                        .failure(
                            MeshCleaningError.unsupportedFileTypes(
                                URLs: invalidFileTypes
                            )
                        )
                    )
                    return
                }
                let asset = MDLAsset(url: fileURL)
                let scene = SCNScene(mdlAsset: asset)
                guard let node = scene.rootNode.childNodes.first else {
                    promise(.failure(MeshCleaningError.missingRootNode))
                    return
                }
                promise(.success(node))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func export(result: ScanCleanResult) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            let scene = SCNScene()
            scene
                .rootNode
                .addChildNode(
                    result.node
                )
            scene
                .write(
                    to: saveURL,
                    options: nil,
                    delegate: nil
                ) { progress, error, stop in
                if let saveError = error {
                    promise(
                        .failure(
                            MeshCleaningError.savingError(
                                error: saveError
                            )
                        )
                    )
                }
                else if Int(progress) == 1 {
                    promise(.success(Void()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

}


