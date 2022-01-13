//
//  DepthDataHelper.swift
//  ScanSDK
//
//  Created by Benjamin Comeau on 2021-10-21.
//  Copyright © 2021 Podform3D. All rights reserved.
//

import Foundation
import AVFoundation
import Accelerate

class DepthDataHelper {
    
    /**
     This function goes through all the depth data for the current frame and converts it to a PointCloud object with the correct coordinates.
     - parameters:
     - depthData:`AVDepthData`
     - videoPixelBuffer: `CVImageBuffer`
     - maximumBoundingBox:`BoundingBox`
     - returns PointCloud?
     */
    static func convertTrueDepthDataToPointCloud(_ depthData: AVDepthData, videoPixelBuffer: CVImageBuffer, maximumBoundingBox: BoundingBox) -> PointCloud? {
        
        // rectify DepthDataMap
        guard let depthFrame = rectifyDepthDataMap(depthData: depthData) else { return nil }
        
        // get cameraCalibrationData
        guard let cameraCalibrationData = depthData.cameraCalibrationData else {
            return nil
        }
        // create a new PointCloud with rectified DepthDataMap
        let pointCloud = PointCloud()
        
        guard var intrinsics = depthData.cameraCalibrationData?.intrinsicMatrix else {
            return nil
        }
        
        let referenceDimensions = depthData.cameraCalibrationData?.intrinsicMatrixReferenceDimensions
        
        let ratio: Float = Float(referenceDimensions!.width) / Float(CVPixelBufferGetWidth(depthFrame))
        intrinsics.columns.0[0] /= ratio
        intrinsics.columns.1[1] /= ratio
        intrinsics.columns.2[0] /= ratio
        intrinsics.columns.2[1] /= ratio
        
        CVPixelBufferLockBaseAddress(depthFrame, .readOnly)
        CVPixelBufferLockBaseAddress(videoPixelBuffer, .readOnly)
        let bufferWidth = CVPixelBufferGetWidth(depthFrame)
        let bufferHeight = CVPixelBufferGetHeight(depthFrame)
        
        let fx = Float(bufferWidth) * (intrinsics.columns.0[0] / Float(bufferWidth))
        let fy = Float(bufferHeight) * (intrinsics.columns.1[1] / Float(bufferHeight))
        let cx = Float(bufferWidth) * (intrinsics.columns.2[0] / Float(bufferWidth))
        let cy = Float(bufferHeight) * (intrinsics.columns.2[1] / Float(bufferHeight))
        
        let depthData = CVPixelBufferGetBaseAddress(depthFrame)!
        let colorData = CVPixelBufferGetBaseAddress(videoPixelBuffer)!
        
        let bytesPerColorPixel = CVPixelBufferGetBytesPerRow(videoPixelBuffer)/CVPixelBufferGetWidth(videoPixelBuffer)
        
        
        var totalNaN: Int = 0
        
        for y in 0...bufferHeight - 1 {
            for x in 0...bufferWidth - 1 {
                
                let actualZ = depthData.assumingMemoryBound(to: Float.self)[x + y * bufferWidth]
                let actualX = (Float(x) - cx) * actualZ / fx;
                let actualY = (Float(y) - cy) * actualZ / fy;
                
                if actualZ.isNaN {
                    totalNaN += 1
                } else if ((maximumBoundingBox.x / -2.0) <= actualX &&
                           actualX <= (maximumBoundingBox.x / 2.0) &&
                           (maximumBoundingBox.y / -2.0) <= actualY &&
                           actualY <= (maximumBoundingBox.y / 2.0) &&
                           actualZ <= maximumBoundingBox.z) {
                    
                    // Point is inside bounding box
                    
                    // Add X
                    pointCloud.pointsXYZ.append(actualX)
                    // Add Y
                    pointCloud.pointsXYZ.append(actualY)
                    // Add Z
                    pointCloud.pointsXYZ.append(actualZ)
                                        
                    
                    // Color
                    let color = colorData.assumingMemoryBound(to: UInt32.self)[x + y * bufferWidth]
                    pointCloud.colorsRGB.append(UInt8(color >> 16 & 0xFF)) // R
                    pointCloud.colorsRGB.append(UInt8(color >> 8 & 0xFF)) // G
                    pointCloud.colorsRGB.append(UInt8(color & 0xFF)) // B
                    
                    
                }
            }
        }
        
        CVPixelBufferUnlockBaseAddress(depthFrame, .readOnly)
        CVPixelBufferUnlockBaseAddress(videoPixelBuffer, .readOnly)
        
        return pointCloud
    }
    
    /**
     Function to rectify the depth data map from lens-distorted to rectilinear coordinate space.
     - parameters:
     - depthData:`AVDepthData`
     - returns CVPixelBuffer?
     */
    static func rectifyDepthDataMap(depthData: AVDepthData) -> CVPixelBuffer? {
        
        let depthDataMap = depthData.depthDataMap
        let depthPixelBuffer = depthData.depthDataMap
        
        // Get camera instrinsics
        guard let cameraCalibrationData = depthData.cameraCalibrationData,
              let lookupTable = cameraCalibrationData.inverseLensDistortionLookupTable else {
                  return nil
              }
        let referenceDimensions: CGSize = cameraCalibrationData.intrinsicMatrixReferenceDimensions
        let opticalCenter: CGPoint = cameraCalibrationData.lensDistortionCenter
        
        let ratio: Float = Float(referenceDimensions.width) / Float(CVPixelBufferGetWidth(depthDataMap))
        let scaledOpticalCenter = CGPoint(x: opticalCenter.x / CGFloat(ratio), y: opticalCenter.y / CGFloat(ratio))
        
        // Get depth stream resolutions and pixel format
        let depthMapWidth = CVPixelBufferGetWidth(depthDataMap)
        let depthMapHeight = CVPixelBufferGetHeight(depthDataMap)
        let depthMapSize = CGSize(width: depthMapWidth, height: depthMapHeight)
        
        
        
        var depthFormatDescription: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: depthPixelBuffer,
                                                     formatDescriptionOut: &depthFormatDescription)
        
        guard let outputPixelBufferPool = DepthToJETConverter.allocateOutputBufferPool(with: depthFormatDescription!,
                                                                                       outputRetainedBufferCountHint: 2) else {return nil}
        
        
        
        var newPixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, outputPixelBufferPool, &newPixelBuffer)
        guard let outputBuffer = newPixelBuffer else {
            print("Allocation failure: Could not get pixel buffer from pool)")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(depthDataMap, .readOnly)
        CVPixelBufferLockBaseAddress(outputBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let inputBytesPerRow = CVPixelBufferGetBytesPerRow(depthDataMap)
        guard let inputBaseAddress = CVPixelBufferGetBaseAddress(depthDataMap) else {
            print("input pointer failed")
            return nil
        }
        let outputBytesPerRow = CVPixelBufferGetBytesPerRow(outputBuffer)
        guard let outputBaseAddress = CVPixelBufferGetBaseAddress(outputBuffer) else {
            print("output pointer failed")
            return nil
        }
        
        // Loop over all output pixels
        for y in 0..<depthMapHeight {
            // Create pointer to output buffer
            let outputRowData = outputBaseAddress + y * outputBytesPerRow
            let outputData = UnsafeMutableBufferPointer(start: outputRowData.assumingMemoryBound(to: Float32.self), count: depthMapWidth)
            
            for x in 0..<depthMapWidth {
                // For each output pixel, do inverse distortion transformation and clamp the points within the bounds of the buffer
                let distortedPoint = CGPoint(x: x, y: y)
                var correctedPoint = lensDistortionPointForPoint(distortedPoint, lookupTable, scaledOpticalCenter, depthMapSize)
                correctedPoint.clamp(bounds: depthMapSize)
                
                // Create pointer to input buffer
                let inputRowData = inputBaseAddress + Int(correctedPoint.y) * inputBytesPerRow
                let inputData = UnsafeBufferPointer(start: inputRowData.assumingMemoryBound(to: Float32.self), count: depthMapWidth)
                
                // Sample pixel value from input buffer and pull into output buffer
                let pixelValue = inputData[Int(correctedPoint.x)]
                outputData[x] = pixelValue
            }
        }
        CVPixelBufferUnlockBaseAddress(depthDataMap, .readOnly)
        CVPixelBufferUnlockBaseAddress(outputBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return outputBuffer
    }
    
}

// MARK: CGPoint
extension CGPoint {
    // Method to clamp a CGPoint within a certain bounds
    mutating func clamp(bounds: CGSize) {
        self.x = min(bounds.width, max(self.x, 0.0))
        self.y = min(bounds.height, max(self.y, 0.0))
    }
}
