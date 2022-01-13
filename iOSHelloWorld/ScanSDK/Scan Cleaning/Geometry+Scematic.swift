//
//  Geometry+Scematic.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-08-16.
//

import SceneKit

extension SCNGeometry {
    
    var vertices: [SCNVector3] {
        sources(for: .vertex)
            .first?
            .vectorData
        ?? []
    }
    
    var colors: [SCNVector3] {
        sources(for: .color)
            .first?
            .vectorData
        ?? []
    }
    
    
    var info: Info {
        var triangles = [Triangle]()
        var edges = [String: Edge]()
        var allVertices = [Vertex]()
        if let element = elements.first {
            let data = element.data
            let arr2 = data.withUnsafeBytes {
                Array(UnsafeBufferPointer<Int32>(start: $0, count: data.count/element.bytesPerIndex))
            }
            let colors = colors
            let vertices = vertices
            print(vertices.count)
            let allColors = colors.count == vertices.count ? colors : nil
            allVertices = vertices
                .enumerated()
                .map { (index, coordinate) in
                    Vertex(
                        coordinate: coordinate,
                        normal: SCNVector3(),//allNormals[index],
                        color: allColors?[index],
                        index: index,
                        edgesKeys: [],
                        triangleIndexes: []
                    )
            }
            var triangleIndex = 0
            for i in stride(from: 0, to: arr2.count, by: 3) {
                let p0 = allVertices[Int(arr2[i])]
                let p1 = allVertices[Int(arr2[i + 1])]
                let p2 = allVertices[Int(arr2[i + 2])]
                let triangle = Triangle(v0: p0,
                                        v1: p1,
                                        v2: p2)
                
                var edge0 = Edge(v0: p0, v1: p1, triangleIndexes: [triangleIndex])
                var edge1 = Edge(v0: p1, v1: p2, triangleIndexes: [triangleIndex])
                var edge2 = Edge(v0: p2, v1: p0, triangleIndexes: [triangleIndex])

                allVertices[Int(arr2[i])]
                    .triangleIndexes
                    .append(triangleIndex)
                allVertices[Int(arr2[i])]
                    .edgesKeys
                    .append(edge0.key)
                allVertices[Int(arr2[i])]
                    .edgesKeys
                    .append(edge2.key)
                allVertices[Int(arr2[i + 1])]
                    .triangleIndexes
                    .append(triangleIndex)
                allVertices[Int(arr2[i + 1])]
                    .edgesKeys
                    .append(edge0.key)
                allVertices[Int(arr2[i + 1])]
                    .edgesKeys
                    .append(edge1.key)
                allVertices[Int(arr2[i + 2])]
                    .triangleIndexes
                    .append(triangleIndex)
                allVertices[Int(arr2[i + 2])]
                    .edgesKeys
                    .append(edge1.key)
                allVertices[Int(arr2[i + 2])]
                    .edgesKeys
                    .append(edge2.key)
                triangles.append(triangle)
                edge0.v0 = allVertices[Int(arr2[i])]
                edge0.v1 = allVertices[Int(arr2[i + 1])]
                edge1.v0 = allVertices[Int(arr2[i + 1])]
                edge1.v1 = allVertices[Int(arr2[i + 2])]
                edge2.v0 = allVertices[Int(arr2[i + 2])]
                edge2.v1 = allVertices[Int(arr2[i])]
                if edges[edge0.key] != nil {
                    edges[edge0.key]?
                        .triangleIndexes
                        .append(triangleIndex)
                } else {
                    edges[edge0.key] = edge0
                }
                if edges[edge1.key] != nil {
                    edges[edge1.key]?
                        .triangleIndexes
                        .append(triangleIndex)
                } else {
                    edges[edge1.key] = edge1
                }
                if edges[edge2.key] != nil {
                    edges[edge2.key]?
                        .triangleIndexes
                        .append(triangleIndex)
                } else {
                    edges[edge2.key] = edge2
                }
                
                triangleIndex += 1
                
            }
        }
        return Info(
            triangles: triangles,
            edges: edges,
            vertices: allVertices
        )
    }
    
    func applying(transform: SCNMatrix4) -> SCNGeometry {
        let info = info
        let verts = info.vertices
            .map { $0.coordinate.transformed(by: transform) }
        let colors = info
            .vertices
            .compactMap { $0.color }
        var faceIndices: [CInt] = []
        info.triangles
            .forEach { triangle in
                faceIndices.append(CInt(triangle.v0.index))
                faceIndices.append(CInt(triangle.v1.index))
                faceIndices.append(CInt(triangle.v2.index))
            }
        let vertexSource = SCNGeometrySource(
            vertices: verts
        )
        let element = SCNGeometryElement(
            indices: faceIndices,
            primitiveType: .triangles
        )
        if colors.count == verts.count {
            let colorSource = SCNGeometrySource(
                colors: colors
            )
            return SCNGeometry(
                sources: [vertexSource, colorSource],
                elements: [element]
            )
        } else {
            return SCNGeometry(
                sources: [vertexSource],
                elements: [element]
            )
        }
    }
    
}

extension SCNGeometry {
    
    struct Info {
        var triangles: [Triangle]
        var vertices: [Vertex]
        var edges: [String: Edge]
        
        init(triangles: [Triangle], edges: [String: Edge], vertices: [Vertex]) {
            self.triangles = triangles
            self.vertices = vertices
            self.edges = edges
        }
        
        func triangle(for vertex: Vertex) -> [Triangle] {
            vertex
                .triangleIndexes
                .compactMap {
                    guard $0 < triangles.count,
                          triangles[$0]
                            .contains(vertex)
                    else { return nil }
                    return triangles[$0]
                }
        }
        
        func edges(for vertex: Vertex) -> [Edge] {
            vertex
                .edgesKeys
                .uniqued()
                .compactMap { edges[$0] }
        }
    }
    
    struct Vertex: Equatable, Hashable {
        var coordinate: SCNVector3
        var normal: SCNVector3
        var color: SCNVector3?
        var index: Int
        var edgesKeys: [String]
        var triangleIndexes: [Int]
        
        func hash(into hasher: inout Hasher) {
            index.hash(into: &hasher)
        }
        
        static func ==(lhs: Vertex, rhs: Vertex) -> Bool {
            lhs.index == rhs.index
        }
    }
    
    struct Triangle: Equatable {
        var v0: Vertex
        var v1: Vertex
        var v2: Vertex
        
        mutating func update(_ vertex: Vertex) {
            if v0.coordinate == vertex.coordinate {
                v0 = vertex
            }
            if v1.coordinate == vertex.coordinate {
                v1 = vertex
            }
            if v2.coordinate == vertex.coordinate {
                v2 = vertex
            }
        }

        func contains(_ coordinate: SCNVector3) -> Bool {
            v0.coordinate == coordinate
                || v1.coordinate == coordinate
                || v2.coordinate == coordinate
        }
        func contains(_ vertex: Vertex) -> Bool {
            v0 == vertex
                || v1 == vertex
                || v2 == vertex
        }
    }
    
    struct Edge: Equatable, Hashable {
        var v0: Vertex
        var v1: Vertex
        var triangleIndexes: [Int]
        var isBoundary: Bool { triangleIndexes.count == 1 }
        var key: String {
            [v0.index, v1.index]
                .sorted()
                .map { "\($0)" }
                .joined(separator: ",")
        }
        func contains(_ vertex: Vertex) -> Bool {
            v0 == vertex || v1 == vertex
        }
        var length: Float {
            v0
                .coordinate
                .distance(vector: v1.coordinate)
        }
        
        static func ==(lhs: Edge, rhs: Edge) -> Bool {
            lhs.key == rhs.key
        }
    }

}


extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}


extension SCNGeometrySource {
    
    convenience init(colors: [SCNVector3]) {
        let colorData = NSData(
            bytes: colors,
            length: MemoryLayout<SCNVector3>.size * colors.count
        )
        self.init(
            data: colorData as Data,
            semantic: .color,
            vectorCount: colors.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<SCNVector3>.size
        )
    }
    
    var vectorData: [SCNVector3] {
        print(semantic)
        let stride = self.dataStride
        let offset = self.dataOffset
        let componentsPerVector = self.componentsPerVector
        let bytesPerVector = componentsPerVector * self.bytesPerComponent
        func vectorFromData<FloatingPoint: BinaryFloatingPoint>(_ float: FloatingPoint.Type, index: Int) -> SCNVector3 {
            assert(bytesPerComponent == MemoryLayout<FloatingPoint>.size)
            let vectorData = UnsafeMutablePointer<FloatingPoint>.allocate(capacity: componentsPerVector)
            let buffer = UnsafeMutableBufferPointer(start: vectorData, count: componentsPerVector)
            let rangeStart = index * stride + offset
            self.data.copyBytes(to: buffer, from: rangeStart..<(rangeStart + bytesPerVector))
            return SCNVector3(
                CGFloat.NativeType(vectorData[0]),
                CGFloat.NativeType(vectorData[1]),
                CGFloat.NativeType(vectorData[2])
            )
        }
        let vectors = [SCNVector3](repeating: SCNVector3Zero, count: vectorCount)
        let vertices = vectors
            .indices
            .map { index -> SCNVector3 in
                switch bytesPerComponent {
                case 4:
                    return vectorFromData(Float32.self, index: index)
                case 8:
                    return vectorFromData(Float64.self, index: index)
                default:
                    return SCNVector3Zero
                }
        }
        return vertices
    }
}
