//
//  GeometryCleaner.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-09-29.
//

import Foundation
import SceneKit
import Combine
import SwiftUI

protocol GeometryCleaner {
    
    func cleanPromise(geometry: SCNGeometry) -> Future<SCNGeometry, Never>
    
    func clean(_ geometry: SCNGeometry) -> SCNGeometry
}


extension GeometryCleaner {
    
    func cleanPromise(geometry: SCNGeometry) -> Future<SCNGeometry, Never> {
        Future { promise in
            DispatchQueue.global(qos: .utility).async {
                let geometry = clean(geometry)
                promise(.success(geometry))
            }
        }
    }
    
    func clean(_ geometry: SCNGeometry) -> SCNGeometry {
        let info = geometry.info
        var polygons = [[Int: Vertex]]()
        let graph = graph(from: info.triangles)
        var unvisitedVertices = graph.vertices
        while let unvisitedVertex = unvisitedVertices.first?.value {
            var polygon = [Int: Vertex]()
            var queue = Queue<Vertex>()
            queue.enqueue(unvisitedVertex)
            unvisitedVertices[unvisitedVertex.coordinate.hashValue] = nil
            polygon[unvisitedVertex.coordinate.hashValue] = unvisitedVertex
            while let vertex = queue.dequeue() {
                let edges = vertex.edges
                guard !edges.isEmpty else {
                    unvisitedVertices[vertex.coordinate.hashValue] = nil
                    continue
                }
                for edge in edges {
                    guard let neighbour = graph.vertices[edge.neighbour(of: vertex.coordinate.hashValue)],
                          unvisitedVertices[neighbour.coordinate.hashValue] != nil
                    else { continue }
                    queue.enqueue(neighbour)
                    unvisitedVertices[neighbour.coordinate.hashValue] = nil
                    polygon[neighbour.coordinate.hashValue] = neighbour
                }
            }
            polygons.append(polygon)
        }
        let largestPolygon = largest(in: polygons)
        guard polygons.count > 1 else { return geometry }
        return filter(info: info, with: largestPolygon)
    }
    
    private func largest(in polygons: [[Int: Vertex]]) -> [Int: Vertex] {
        var largestPolygon = [Int: Vertex]()
        polygons.forEach {
            guard largestPolygon.count < $0.count else { return }
            largestPolygon = $0
        }
        return largestPolygon
    }
    
    private func filter(info: SCNGeometry.Info, with largestPolygon: [Int: Vertex]) -> SCNGeometry {
        var filteredVertices = [SCNGeometry.Vertex]()
        var filteredTriangles = [Int: SCNGeometry.Triangle]()
        let vertices = info.vertices
        info
            .triangles
            .enumerated()
            .forEach { filteredTriangles[$0] = $1 }
        vertices
            .forEach { (vertex) in
                if largestPolygon[vertex.coordinate.hashValue] == nil {
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
        let verts: [SCNVector3] = filteredVertices
            .map { $0.coordinate }
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
        let colors = filteredVertices
            .compactMap { $0.color }
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
    
    private func graph(from triangles: [SCNGeometry.Triangle]) -> Graph {
        var vertices = [Int: Vertex]()
        triangles.forEach {
            if vertices[$0.v0.coordinate.hashValue] == nil {
                vertices[$0.v0.coordinate.hashValue] = Vertex(coordinate: $0.v0.coordinate, edges: [])
            }
            if vertices[$0.v1.coordinate.hashValue] == nil {
                vertices[$0.v1.coordinate.hashValue] = Vertex(coordinate: $0.v1.coordinate, edges: [])
            }
            if vertices[$0.v2.coordinate.hashValue] == nil {
                vertices[$0.v2.coordinate.hashValue] = Vertex(coordinate: $0.v2.coordinate, edges: [])
            }
            vertices[$0.v0.coordinate.hashValue]?
                .edges
                .append(Edge(v0Hash: $0.v0.coordinate.hashValue,
                             v1Hash: $0.v1.coordinate.hashValue))
            vertices[$0.v1.coordinate.hashValue]?
                .edges
                .append(Edge(v0Hash: $0.v1.coordinate.hashValue,
                             v1Hash: $0.v2.coordinate.hashValue))
            vertices[$0.v2.coordinate.hashValue]?
                .edges
                .append(Edge(v0Hash: $0.v2.coordinate.hashValue,
                             v1Hash: $0.v0.coordinate.hashValue))
        }
        return Graph(vertices: vertices)
    }
    
}

private struct Graph {
    
    var vertices: [Int: Vertex]
    
}

private struct Vertex {
    
    var coordinate: SCNVector3
    var edges: [Edge]
    
}

private struct Edge: Hashable {
    
    var v0Hash: Int
    var v1Hash: Int
    
    func hash(into hasher: inout Hasher) {
        "\(v0Hash),\(v1Hash)"
            .hash(into: &hasher)
    }
    
    func neighbour(of vertex: Int) -> Int {
        vertex == v0Hash ? v1Hash : v0Hash
    }
}


