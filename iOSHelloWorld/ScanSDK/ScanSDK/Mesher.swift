//
//  Mesher.swift
//  ScanSDK
//
//  Created by Benjamin Comeau on 2021-10-26.
//  Copyright © 2021 Podform3D. All rights reserved.
//

import Foundation

struct cloud {
    var points: Array<Float> = []
    var normals: Array<Float> = []
    var colors: Array<UInt8> = []
}

class Mesher {
    // High resolution config
    let decimationSize: Float = 0.003
    let meshDecimationSize: Float = 0.00125
    let registrationTolerance: Float = 0.0001
    let registrationIteration: Int32 = 20
    let registrationSearchDist: Float = 0.01
    let regPointProp: Float = 0.0
    let meshDepth: Int = 7
    let meshThread: Int = 1
    let meshOpenningDist: Float = 0.005
    let bbMin: Array<Float> = [-0.2, -0.2, 0.1]
    let bbMax: Array<Float> = [ 0.2, 0.2, 0.2]
    
    func registerPointCloud(newPointCloud:PointCloud, registeredPointCloud: PointCloud) -> PointCloud {
        
        var regcount: Int = 0;
        
        var out_pts: Array<Float> = registeredPointCloud.pointsXYZ
        var out_normal: Array<Float> = registeredPointCloud.normals
        var out_color: Array<UInt8> = registeredPointCloud.colorsRGB
        
        var timeNow = timeval()
        
        NSLog("Processing")
        
        // Precess frame
        var tSProcess = timeval()
        gettimeofday(&tSProcess, nil)
        
        let processResult = MesherSDK.processFrame(inPoint: newPointCloud.pointsXYZ, inColor: newPointCloud.colorsRGB, inPoint2: out_pts, inNormal2: out_normal, inColor2: out_color, inBbMin: bbMin, inBbMax: bbMax, inSearchDistance: registrationSearchDist, inPtsProp: regPointProp, inTolerance: registrationTolerance, inMaxIteration: registrationIteration, inVoxelSizeInput: decimationSize, inVoxelSizeOutput: meshDecimationSize, inKnn: 5)
        
        
        gettimeofday(&timeNow, nil)
        let ms_process = (timeNow.tv_sec - tSProcess.tv_sec) * 1000 + Int((timeNow.tv_usec - tSProcess.tv_usec)) / 1000
        NSLog("Process in: %d(ms)", ms_process)
        
        if (processResult.success) {
            regcount += 1
            out_pts = processResult.outPoint
            out_normal = processResult.outNormal ?? []
            out_color = processResult.outColor ?? []
        }
        
        let result = PointCloud()
        result.pointsXYZ = out_pts
        result.normals = out_normal
        result.colorsRGB = out_color
        
        return result
    }
    
    
    func mesh(_ pointCloud: PointCloud) -> (vertices:Array<Float>, faces: Array<Int32>, colors: Array<UInt8>) {
        
        var faces: Array<Int32>! = nil
        var vertices: Array<Float>! = nil
        
        var timeNow = timeval()
        // Compute mesh
        var tsMesh = timeval()
        gettimeofday(&tsMesh, nil)
        let meshRet = MesherSDK.mesh(inPoint: pointCloud.pointsXYZ, inNormal: pointCloud.normals, inOpeningDistance: meshOpenningDist, inDepth: meshDepth, nbThread: meshThread)
        vertices = meshRet.outVert
        faces = meshRet.outFaceVertId
        gettimeofday(&timeNow, nil)
        let ms_mesh = (timeNow.tv_sec - tsMesh.tv_sec) * 1000 + Int((timeNow.tv_usec - tsMesh.tv_usec)) / 1000
        NSLog("Mesh computation in: %d(ms)", ms_mesh)
        
        
        // Find closest color
        let color = MesherSDK.findPointClosetColor(inPoint: pointCloud.pointsXYZ, inColor: pointCloud.colorsRGB, inDestPoint: vertices)
        
        return (vertices, faces, color)
    }
    
}
