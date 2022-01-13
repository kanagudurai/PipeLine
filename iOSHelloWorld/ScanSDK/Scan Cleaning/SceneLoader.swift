//
//  SceneLoader.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-09-04.
//

import Foundation
import SceneKit
import ModelIO
import SwiftUI

protocol SceneLoader {
    func loadScene(at fileURL: URL) -> SCNScene
}

extension SceneLoader {
    
    func loadScene(at fileURL: URL) -> SCNScene {
        let asset = MDLAsset(url: fileURL)
        let object = asset.object(at: 0)
        let transform = MDLTransform()
        transform.rotation = vector_float3(.pi , 0, .pi)
        object.transform = transform
        return SCNScene(mdlAsset: asset)
    }
}

extension SceneLoader where Self: PreviewProvider {
    
    static func loadPreviewNode() -> SCNNode {
        loadPreviewScene().rootNode.childNodes.first!
    }
     
    static func loadPreviewScene() -> SCNScene {
        SCNScene(
            mdlAsset:
                    MDLAsset(url:
                                Bundle
                                .main
                                .url(forResource: "leftfoot",
                                     withExtension: "obj")!
                    )
        )
    }
    
}

