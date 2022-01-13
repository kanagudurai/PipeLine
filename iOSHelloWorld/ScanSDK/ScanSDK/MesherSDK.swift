//
//  Swift-SDK.swift
//  MesherSDK
//
//  Created by intozoom on 10/18/21.
//

import Foundation

class MesherSDK: NSObject {
    /**
     Decimate a point cloud.
     
     - Parameters
     Array<Float> inPoint: input point cloud. A sequence of XYZ float.
     Array<Float> inNormal: input point cloud normals. A sequence of XYZ float. Can be NULL.
     Float inVoxelSize: Size of the voxel to use.
     Array<UInt8> inColor: input point cloud colors. A sequence of RGB byte. Can be NULL.
     
     - Return
     Array<Float> outPoint: output point cloud. A sequence of XYZ float. Must be deleted by the caller.
     Array<Float> outNormal: output point cloud normals. A sequence of XYZ float. Will be NULL if in_normal is NULL.
     Array<UInt8> outColor: output point cloud colors. A sequence of RGB byte. Will be NULL if in_color is NULL. Must be deleted by the caller.
     
     - Example
     let returnVal = MesherSDK.decimate(intPoint: inPoint, inNormal: inNormal, outColor: outColor, inVoxelSize: boxelSize )
     outPoint = returnVal.outPoint
     outNormal = returnVal.outNormal
     outColor = returnVal.outColor
     
     */
    class func decimate(inPoint: Array<Float>?, inNormal: Array<Float>?, inColor: Array<UInt8>?, inVoxelSize: Float) -> (outPoint: Array<Float>, outNormal: Array<Float>?, outColor: Array<UInt8>?)
    {
        let rawInPoint = UnsafeMutablePointer<Float>(mutating: inPoint)
        let rawInNormal = UnsafeMutablePointer<Float>(mutating: inNormal)
        let rawInColor = UnsafeMutablePointer<UInt8>(mutating: inColor)
        let retValue = WrapperSDK.decimateWith(inPoint:rawInPoint , withInNormal:rawInNormal, withColor: rawInColor , withLen: Int32(inPoint!.count), withInVexelSize: inVoxelSize) as! [String: Any]
        return (outPoint:retValue["outPoint"] as! Array<Float>, outNormal:retValue["outNormal"] as? Array<Float>, outColor:retValue["outColor"] as? Array<UInt8>)
    }
    
    /**
     Compute normals of a point cloud.
     
     - Parameters
     Array<Float> inPoint: input point cloud. A sequence of XYZ float.
     Int inKnn: Number of nearest point used to compute the normal. Must be at least 2.
     
     - Return
     Bool success: True if the computation succeeded, false otherwise.
     Array<Float> outNormal: output point cloud normals. A sequence of XYZ float.
     
     - Example
     let returnVal = MesherSDK.computeNormals(inPoint: inPoint, inKnn: inKnn)
     success = returnVal.success
     outNormal = returnVal.outNormal
     
     */
    class func computeNormals(inPoint: Array<Float>?, inKnn: Int) -> (success: Bool, outNormal: Array<Float>?)
    {
        let rawInPoint = UnsafeMutablePointer<Float>(mutating: inPoint)
        let retValue = WrapperSDK.computeNormalsWith(inPoint: rawInPoint, withLen: Int32(inPoint!.count), withInKnn: Int32(inKnn)) as! [String: Any]
        return (success: (retValue["success"] as! NSNumber).boolValue, outNormal: retValue["outNormal"] as? Array<Float>)
    }
    
    
    /**
     Compute Poisson cloud meshing based on vertices and point cloud normals.
     
     - Parameters
     Array<Float> in_point: input point cloud. A sequence of XYZ float.
     Array<Float> in_normal: input point cloud normals. A sequence of XYZ float.
     Float inOpeningDistance: Maximum distance from which a mesh tri centroid must from the tri to be considered valid.
     Int inDepth: Depth of the octree structure of the meshing method. It control the level of interpolation.
     Int nbThread: Number of thread to use.
     
     - Return
     Array<Float> outVert: output mesh vertices. A sequence of XYZ float.
     Array<Int> outFaceVertId: output mesh faces. A sequence of 3 index referring to out_vert.
     
     - Example
     let returnVal = MesherSDK.mesh(inPoint: inPoint, inNormal: inNormal, inOpeningDistance: openingDistance, inDepth: inDepth )
     outVert = returnVal.outVert
     outFaceVertId = returnVal.outFaceVertId
     
     */
    class func mesh(inPoint: Array<Float>?, inNormal: Array<Float>?, inOpeningDistance: Float, inDepth: Int = 6, nbThread: Int) -> (outVert: Array<Float>, outFaceVertId: Array<Int32>)
    {
        let rawInPoint = UnsafeMutablePointer<Float>(mutating: inPoint)
        let rawInNormal = UnsafeMutablePointer<Float>(mutating: inNormal)
        let retValue = WrapperSDK.meshWith(inPoint: rawInPoint, withInNormal: rawInNormal, withLen: Int32(inPoint!.count), withInOpeningDistance: inOpeningDistance, withInDepth: Int32(inDepth), withNbThread: Int32(nbThread)) as! [String: Array<Any>]
        
        return (outVert: retValue["outVert"] as! Array<Float>, outFaceVertId: retValue["outFaceVertId"] as! Array<Int32>)
    }
    
    
    /**
     Intersect a point cloud with a bounding box
     
     - Parameters
     Array<Float> inPoint: input point cloud. A sequence of XYZ float.
     Array<Float> inNormal: input point cloud normals. A sequence of XYZ float. Can be NULL.
     Array<UInt8> inColor: input point cloud colors. A sequence of RGB byte. Can be NULL.
     Float inSearchDistance: Radius the registration use arround a point to search for reference points for the registration. Will be used to align frame in Z.
     Array<Float> inBbMin: BB minimum XYZ (array of 3 float).
     Array<Float> inBbMax: BB maximum XYZ (array of 3 float).
     
     - Return
     Array<Float> outPoint: output point cloud. A sequence of XYZ float. Must be deleted by the caller.
     Array<Float> outNormal: output point cloud normals. A sequence of XYZ float. Will be NULL if in_normal is NULL.
     Array<UInt8> outColor: output point cloud colors. A sequence of RGB byte. Will be NULL if in_color is NULL. Must be deleted by the caller.
     
     - Example
     let returnVal = MesherSDK.intersect(inPoint: inPoint, inNormal: inNormal, inBbMin: bbMin, inBbMax: bbMax )
     outPoint = returnVal.outPoint
     outNormal = returnVal.outNormal
     outColor = returnVal.outColor
     
     */
    class func intersect(inPoint: Array<Float>?, inNormal: Array<Float>?, inColor: Array<UInt8>?, inSearchDistance: Float, inBbMin: Array<Float>, inBbMax: Array<Float>) -> (outPoint: Array<Float>, outNormal: Array<Float>?, outColor: Array<UInt8>?)
    {
        let rawInPoint = UnsafeMutablePointer<Float>(mutating: inPoint)
        let rawInNormal = UnsafeMutablePointer<Float>(mutating: inNormal)
        let rawInColor = UnsafeMutablePointer<UInt8>(mutating: inColor)
        let retValue = WrapperSDK.intersectWith(inPoint: rawInPoint, withInNormal: rawInNormal, withInColor: rawInColor, withLen: Int32(inPoint!.count), withInSearchDistance: inSearchDistance, withInBBMin: inBbMin, withInBBMax: inBbMax) as! [String: Any]
        
        
        
        return (outPoint: retValue["outPoint"] as! Array<Float>, outNormal: retValue["outNormal"] as? Array<Float>, outColor:retValue["outColor"] as? Array<UInt8> )
    }
    
    
    /**
     Registration of a point cloud using a source point cloud and normals. Registration (rigid ICP) is done using a combination of criteria (planes and points).
     
     - Parameters
     Array<Float> inPoint1: input reference point cloud. A sequence of XYZ float.
     Array<Float> inNormal1: input reference point cloud normals. A sequence of XYZ float. Can be NULL.
     Array<Float> inPoint2: input point cloud to register. A sequence of XYZ float.
     Array<Float> inNormal2: input reference point cloud normals. A sequence of XYZ float. Can be NULL.
     Float inSearchDistance: Radius the algorithm use around a point to search for reference points for the registration.
     Float inPtsPlaneRatio: Proportion of importance to point versus plane. Should be btw 0 (100% planes) an 1 (100% points).
     Float inTolerance: convergence value for the ICP.
     Int inMaxIteration: Maximum number of iteration(ICP) to try to reach in_tolerance.
     
     - Return
     Bool success: True if the computation converger, false otherwise.
     Array<Float> outPoint: output point cloud that is the registrated version of inPoint2. A sequence of XYZ float. NULL if the function return false.
     
     - Example
     let returnVal = MesherSDK.registration(inPoint1: inPoint1, inNormal: inNormal, inPoint2: inPoint2, insearchDistance: searchDistance, inPtsPlaneRatio: planeRation, inTolerance: lerance, inMaxIteraction: maxIteraction)
     success = returnVal.success
     outPoint = returnVal.outPoint
     
     */
    class func registration(inPoint1: Array<Float>?, inNormal1: Array<Float>?, inPoint2: Array<Float>?, inNormal2: Array<Float>?, inSearchDistance: Float, inPtsPlaneRatio: Float = 0.5, inTolerance: Float = 1e-4, inMaxInteration: Int32 = 50 ) -> (success: Bool, outPoint: Array<Float>, outNormal: Array<Float>)
    {
        let rawInPoint1 = UnsafeMutablePointer<Float>(mutating: inPoint1)
        let rawInNormal1 = UnsafeMutablePointer<Float>(mutating: inNormal1)
        let rawInPoint2 = UnsafeMutablePointer<Float>(mutating: inPoint2)
        let rawInNormal2 = UnsafeMutablePointer<Float>(mutating: inNormal2)
        let retValue = WrapperSDK.registrationWith(inPoint1: rawInPoint1, withInNormal1: rawInNormal1, withLen1: Int32(inPoint1!.count), withInPoint2: rawInPoint2, withInNormal2: rawInNormal2, withLen2: Int32(inPoint2!.count), withInSearchDistance: inSearchDistance, withInPtsPlaneRatio: inPtsPlaneRatio, withInTolerance: inTolerance, withInMaxInteration: inMaxInteration);
        return (success: (retValue!["success"] as! NSNumber).boolValue, outPoint: retValue!["outPoint"] as! Array<Float>, outNormal: retValue!["outNormal"] as! Array<Float>)
    }
    
    
    /**
     Write a mesh or point cloud to an OBJ file.
     
     - Parameters
     Array<Float> inVert: input mesh vertices. A sequence of XYZ float.
     Array<Int> inFaceVertId: mesh faces. A sequence of 3 index referring to in_vert.
     Array<Float> inColor: input mesh's vertices color array.
     String fileName: Filename.
     
     - Return
     Bool success: True if the computation succeeded, false otherwise.
     
     - Example
     let success = MesherSDK.writeObj(inVert: inVert, inFaceVertId: inFaceVertId, inColor: inColor, inFileName: fileName)
     
     */
    class func writeObj(inVert: Array<Float>?, inFaceVertId: Array<Int32>?, inColor: Array<Float>?, inFileName: String) -> Bool
    {
        let rawInVert = UnsafeMutablePointer<Float>(mutating: inVert)
        let rawInColor = UnsafeMutablePointer<Float>(mutating: inColor)
        let rawInFaceVertId = UnsafeMutablePointer<Int32>(mutating: inFaceVertId)
        return WrapperSDK.writeObjWith(inVert: rawInVert, withInColor: rawInColor, withVertLen: Int32(inVert!.count), withInFaceVertId: rawInFaceVertId, withFaceLen: Int32(inFaceVertId!.count), withInFileName: inFileName)
    }
    
    
    /**
     Write a mesh to an PLY file.
     
     - Parameters
     Array<Float> inVert: input mesh vertices. A sequence of XYZ float.
     Array<Int> inFaceVertId: mesh faces. A sequence of 3 index referring to in_vert.
     String fileName: Filename.
     
     - Return
     return Bool success: True if the computation succeeded, false otherwise.
     
     - Example
     let success = MesherSDK.writePly(inVert: inVert, inFaceVertId: inFaceVertId, inFileName: fileName)
     
     */
    class func writePly(inVert: Array<Float>?, inFaceVertId: Array<Int32>?, inColor: Array<UInt8>?, inFileName: String) -> Bool
    {
        let rawInVert = UnsafeMutablePointer<Float>(mutating: inVert)
        let rawInFaceVertId = UnsafeMutablePointer<Int32>(mutating: inFaceVertId)
        let rawInColor = UnsafeMutablePointer<UInt8>(mutating: inColor)
        return WrapperSDK.writePlyWith(inVert: rawInVert, withInColor: rawInColor, withVertLen: Int32(inVert!.count), withInFaceVertId: rawInFaceVertId, withFaceLen: Int32(inFaceVertId?.count ?? 0), withInFileName: inFileName)
    }
    
    
    /**
     * \brief Extract point from a point cloud that are at a specified distance from a reference surface.
     
     * \param Array<Float> inPoint: input point cloud. A sequence of XYZ float that represent the reference surface.
     * \param Array<Float> inPoint2: input point cloud where point will be extracted. A sequence of XYZ float.
     * \param Array<Float> inNormal2: input normal of in_point2. A sequence of XYZ float.
     * \param Float inMaxDistance: distance from the reference surface where point will be extracted.
     *
     * \return
     * Array<Float> outPoint: output point cloud. A sequence of XYZ float. Must be deleted by the caller.
     * Array<Float> outNormal: output point cloud normals. A sequence of XYZ float. Will be NULL if in_normal is NULL. Must be deleted by the caller.
     */
    class func extractOutOfSurfacePoint(inPoint: Array<Float>?, inPoint2: Array<Float>?, inNormal2: Array<Float>?, inMaxDistance: Float) -> (outPoint: Array<Float>, outNormal: Array<Float>)
    {
        let rawInPoint = UnsafeMutablePointer<Float>(mutating: inPoint)
        let rawInPoint2 = UnsafeMutablePointer<Float>(mutating: inPoint2)
        let rawInNormal2 = UnsafeMutablePointer<Float>(mutating: inNormal2)
        
        let retValue = WrapperSDK.extractOutOfSurfacePointWith(inPoint: rawInPoint, withInPointLen: Int32(inPoint!.count), withInPoint2: rawInPoint2, withInNormal2: rawInNormal2, withInPoint2Len: Int32(inPoint2!.count), withInMaxDistance: inMaxDistance) as! [String: Array<Float>]
        
        return (outPoint: retValue["outPoint"]!, outNormal: retValue["outNormal"]!)
        
    }
    
    
    /**
     * \brief Intersect a point cloud with an axis-aligned bounding box
     *
     * \param Array<Float> inPoint: input point cloud. A sequence of XYZ float.
     * \param Array<UInt8> inColor: input point cloud color. A sequence of RGB bytes.
     * \param Array<Float> inDestPoint: point cloud to be colored. A sequence of XYZ float.
     *
     * \return
     * Array<UInt8> outColor: A sequence of in_dest_point_len RGB bytes to color in_dest_point. Must be deleted by the caller.
     */
    class func findPointClosetColor(inPoint: Array<Float>?, inColor: Array<UInt8>?, inDestPoint: Array<Float>?) -> Array<UInt8>
    {
        let rawInPoint = UnsafeMutablePointer<Float>(mutating: inPoint)
        let rawInColor = UnsafeMutablePointer<UInt8>(mutating: inColor)
        let rawInDestPoint = UnsafeMutablePointer<Float>(mutating: inDestPoint)
        
        let retValue = WrapperSDK.findPointClosetColorWith(inPoint: rawInPoint, withInColor: rawInColor, withInPointLen: Int32(inPoint!.count), withInDestPoint: rawInDestPoint, withInDestPointLen: Int32(inDestPoint!.count)) as! Array<UInt8>
        return retValue
    }
    
    
    /**
     Process a frame. Align a point cloud to the frame and return a combined version.
     
     - Parameters
     Array<Float> inPoint: input point cloud. A sequence of XYZ float.
     Array<UInt8> inColor: input point cloud color. A sequence of RGB bytes.
     Array<Float> inPoint2: input point cloud. A sequence of XYZ float.
     Array<Float> inNormal2: input normal of in_point2. A sequence of XYZ float.
     Array<UInt8> inColor2: input point cloud color. A sequence of RGB bytes.
     Array<Float> inBBMin: BB minimum XYZ (array of 3 float).
     Array<Float> inBBMax: BB maximum XYZ (array of 3 float).
     Float inSearchDistance: Radius the algorithm use arround a point to search for reference points for the registration.
     Float inPtsProp: Proportion of importance to point versus plane. Should be btw 0 (100% planes) an 1 (100% points).
     Float inTolerance: convergence value for the ICP.
     Int  inMaxIteration: Maximum number of iteration(ICP) to try to reach in_tolerance.
     Float inVoxelSizeInput: Size of the voxel to use to decimate the input frame.
     Float  inVoxelSizeOutput: Size of the voxel to use to decimate the output cloud.
     Int inKnn: Number of nearest point used to compote the normal. Must be at least 2.
     
     - Return
     Bool success: True if the computation succeeded, false otherwise.
     Array<Float> outPoint: output point cloud. A sequence of XYZ float. Must be deleted by the caller.
     Array<Float> outNormal: output point cloud normals. A sequence of XYZ float. Will be NULL if in_normal is NULL.
     Array<UInt8> outColor: output point cloud colors. A sequence of RGB byte. Will be NULL if in_color is NULL. Must be deleted by the caller.
     
     - Example
     let returnVal = MesherSDK.processFrame(...)
     outPoint = returnVal.outPoint
     outNormal = returnVal.outNormal
     outColor = returnVal.outColor
     */
    class func processFrame(inPoint: Array<Float>?, inColor: Array<UInt8>?, inPoint2: Array<Float>?, inNormal2: Array<Float>?, inColor2: Array<UInt8>?, inBbMin: Array<Float>, inBbMax: Array<Float>, inSearchDistance: Float, inPtsProp: Float, inTolerance: Float, inMaxIteration: Int32, inVoxelSizeInput:Float, inVoxelSizeOutput:Float, inKnn: Int)-> (success: Bool, outPoint: Array<Float>, outNormal: Array<Float>?, outColor: Array<UInt8>?)
    {
        
        let rawInPoint = UnsafeMutablePointer<Float>(mutating: inPoint)
        let rawInColor = UnsafeMutablePointer<UInt8>(mutating: inColor)
        
        let rawInPoint2 = UnsafeMutablePointer<Float>(mutating: inPoint2)
        let rawInNormal2 = UnsafeMutablePointer<Float>(mutating: inNormal2)
        let rawInColor2 = UnsafeMutablePointer<UInt8>(mutating: inColor2)
        
        
        let retValue = WrapperSDK.processFrameWithWith(inPoint: rawInPoint, withInColor: rawInColor, withInPointLen: Int32(inPoint!.count), withInPoint2: rawInPoint2, withInNormal2: rawInNormal2, withInColor2: rawInColor2, withInPointLen2: Int32(inPoint2!.count), withInBBMin: inBbMin, withInBBMax: inBbMax, withInSearchDistance: inSearchDistance, withInPtsProp: inPtsProp, withInTolerance: inTolerance, withInMaxIteration: inMaxIteration, withInVoxelSizeInput: inVoxelSizeInput, withInVoxelSizeOutput: inVoxelSizeOutput, withInKnn: Int32(inKnn)) as! [String: Any]
        
        return (success: (retValue["success"] as! NSNumber).boolValue, outPoint: retValue["outPoint"] as! Array<Float>, outNormal: retValue["outNormal"] as? Array<Float>, outColor:retValue["outColor"] as? Array<UInt8> )
    }
}
