//
//  GeometrySlicer.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-08-23.
//

import SceneKit
import Combine

protocol GeometrySlicer {
    
    func slicePromise(geometry: SCNGeometry,
                      boundingBox: CleanerBoundBox,
                      translation: SCNVector3,
                      transform: SCNMatrix4)
    -> Future<SCNGeometry, Never>
    
    func slice(geometry: SCNGeometry,
               boundingBox: CleanerBoundBox,
               translation: SCNVector3,
               transform: SCNMatrix4)
    -> SCNGeometry
}

extension GeometrySlicer {
    
    func slicePromise(
        geometry: SCNGeometry,
        boundingBox: CleanerBoundBox,
        translation: SCNVector3,
        transform: SCNMatrix4
    ) -> Future<SCNGeometry, Never> {
        Future { promise in
            DispatchQueue.global(qos: .utility).async {
                let geometry = slice(
                    geometry: geometry,
                    boundingBox: boundingBox,
                    translation: translation,
                    transform: transform
                )
                promise(.success(geometry))
            }
        }
    }
    
    func slice(geometry: SCNGeometry,
               boundingBox: CleanerBoundBox,
               translation: SCNVector3,
               transform: SCNMatrix4) -> SCNGeometry {
        let info = geometry.info
        var filteredVertices = [SCNGeometry.Vertex]()
        var filteredTriangles = [Int: SCNGeometry.Triangle]()
        let vertices = info.vertices
        let newBoundingBox = boundingBox
        info
            .triangles
            .enumerated()
            .forEach { filteredTriangles[$0] = $1 }
        vertices
            .forEach { (vertex) in
                if !newBoundingBox
                        .contains(
                            /*(*/vertex.coordinate //- translation)
                                //.transformed(by: transform)
                        ) {
                    vertex
                        .triangleIndexes
                        .forEach { filteredTriangles[$0] = nil }
                } else {
                    filteredVertices.append(vertex)
                }
            }
        filteredVertices
            .enumerated()
            .forEach { (index, vertex) in
                let newVertex = SCNGeometry.Vertex(
                    coordinate: vertex.coordinate,
                    normal: vertex.normal,
                    index: index,
                    edgesKeys: [],
                    triangleIndexes: []
                )
                vertex
                    .triangleIndexes
                    .forEach {
                        filteredTriangles[$0]?.update(newVertex)
                    }
            }

        var faceIndices: [CInt] = []
        let verts: [SCNVector3] = filteredVertices.map {
            /*(*/$0.coordinate //- translation)
                //.transformed(by: transform)
        }
        let colors = filteredVertices
            .compactMap { $0.color }
        filteredTriangles
            .values
            .forEach { triangle in
                let areTwoFacesIndicesEqual =
                triangle.v0.index == triangle.v1.index
                || triangle.v0.index == triangle.v2.index
                || triangle.v1.index == triangle.v2.index
                guard !areTwoFacesIndicesEqual else { return }
                faceIndices.append(CInt(triangle.v0.index))
                faceIndices.append(CInt(triangle.v1.index))
                faceIndices.append(CInt(triangle.v2.index))
            }
        let vertexSource = SCNGeometrySource(vertices: verts)
        let element = SCNGeometryElement(
            indices: faceIndices,
            primitiveType: .triangles
        )
        if colors.count != filteredVertices.count {
            return SCNGeometry(
                sources: [vertexSource],
                elements: [element]
            )
        } else {
            let colorSource = SCNGeometrySource(
                colors: colors
            )
            return SCNGeometry(
                sources: [vertexSource, colorSource],
                elements: [element]
            )
        }
    }
    
}

private struct VertexContainer {
    
    var isDeleted: Bool
    var vertex: SCNGeometry.Vertex

}

struct CleanerBoundBox {
    let min: SCNVector3
    let max: SCNVector3

    var origin: SCNVector3 {
        return (max + min) * 0.5
    }

    init(box: (min: SCNVector3, max: SCNVector3)) {
        min = box.min
        max = box.max
    }

    func contains(_ point: SCNVector3) -> Bool {
        let contains =
            min.x <= point.x
            &&
            min.y <= point.y
            &&
            min.z <= point.z
            &&
            max.x >= point.x
            &&
            max.y >= point.y
            &&
            max.z >= point.z
        return contains
    }
}
