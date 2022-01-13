//
//  ScanSDK.swift
//  ScanSDK
//
//  Created by Melek Ramki on 2021-10-21.
//  Copyright © 2021 Podform3D. All rights reserved.
//

import UIKit
import AVFoundation
import CoreVideo
import MobileCoreServices


public struct BoundingBox {
    var x: Float = Float.infinity
    var y: Float = Float.infinity
    var z: Float = Float.infinity
}

@available(iOS 13, *)
public class ScanSDK {
    // MARK: ScanSDK private properties
    
    /// Shared ScanSDK instance
    private static var _instance: ScanSDK?
    
    /// ScanSDKDelegate
    public weak var delegate: ScanSDKDelegate?
    
    
    /// Scan configuration
    private var frameCountToCapture: Int = 0
    private var delayBetweenFrame: UInt = 0
    private(set) var maximumBoundingBox: BoundingBox = BoundingBox()
    private var saveCapturedFrame: Bool = false
    
    /// Scan progress
    private var framecount: Int = 0
    private var lastCaptureTimeInMs: UInt = 0
    
    /// Scan data
    private(set) var registeredPointCloud = PointCloud()
    private(set) var mesh: (vertices:Array<Float>, faces: [Int32], colors: Array<UInt8>) = ([], [], [])
    
    private let mesherQueue = DispatchQueue(label: "scanSDK.mesher.queue", attributes: .concurrent)
    
    /// Initializes the SDK, this must be called before ScanSDK.get().
    public static func initialize() {
        guard _instance == nil else { return }
        _instance = ScanSDK()
    }
    
    /// Returns the ScanSDK instance.
    public static func get() -> ScanSDK {
        guard let instance = _instance else {
            fatalError("ScanSDK.initialize must be called before ScanSDK.get")
        }
        return instance
    }
    
    /// Returns if the device has scanning capabilities
    public func isDeviceSupported() -> Bool {
        let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera],
                                                                           mediaType: .video,
                                                                           position: .front)
        if videoDeviceDiscoverySession.devices.first != nil {
#if DEBUG
            print("Found video device")
#endif
            return true
        } else {
            print("Could not find any video device")
            return false
        }
    }
    
    /// Current Status of the Scan
    public var scanStatus: ScanStatus = .stopped {
        didSet {
            // notify delegates
            delegate?.scanStatusDidChange(scanStatus: scanStatus)
        }
    }
    
    /**
     Configures the ScanSessionManager's Scan Capture Session with:
     - parameters:
     - frameCountToCapture:`Int` The number of frames to capture, assign `0` for unlimited frames.
     - delayBetweenFrame:`UInt`Delay between frames in Milliseconds, only assign positive integers.
     - saveFrame: `Bool` Save the captured frame on the device. Only use in debug. Default `false`.
     - maximumBoundingBox:  `BoundingBox` Limit capture to the maximumBoundingBox, in `meters`.
     */
    public func configureScan(frameCountToCapture: Int, delayBetweenFrame: UInt, saveFrame: Bool = false, maximumBoundingBox: BoundingBox) {
        self.frameCountToCapture = frameCountToCapture
        self.delayBetweenFrame = delayBetweenFrame
        self.saveCapturedFrame = saveFrame
        self.maximumBoundingBox = maximumBoundingBox
    }
    
    /**
     Starts a Scan
     - parameters:
     - None
     */
    public func startScan() {
        // Clear captured points
        self.clearCapturedPointClouds()
        
        // Clear mesh
        self.clearMesh()
        
        // Set Scan Status
        scanStatus = .inProgress
    }
    
    /**
     Stops a Scan
     - parameters:
     - None
     */
    public func stopScan() {
        scanStatus = .stopped
    }
    
    /**
     Process depht frame
     - parameters:
     - depthData:`AVDepthData`
     - videoPixelBuffer: `CVImageBuffer`
     */
    public func processDepthFrame(depthData: AVDepthData, videoPixelBuffer: CVImageBuffer) {
        
        // Check if Scan is inProgress
        if self.scanStatus == .inProgress {
            // Check if delay between frames is reached
            if self.lastCaptureTimeInMs + self.delayBetweenFrame <= Date().toMillis() {
                // Check frameCountToCapture
                if self.frameCountToCapture > 0 &&  self.framecount < self.frameCountToCapture {
                    
                    self.framecount+=1
                    self.lastCaptureTimeInMs = Date().toMillis()
                    
                    // Call capturePointCloud
                    self.capturePointCloud(depthData: depthData, videoPixelBuffer: videoPixelBuffer, maximumBoundingBox: self.maximumBoundingBox, frameIndex: self.framecount)
                    
                } else if self.framecount == self.frameCountToCapture{
                    self.scanStatus = .complete
                }
            }
        }
    }
    
    /**
     Captures Point Clouds
     - parameters:
     - depthData:`AVDepthData`
     - videoPixelBuffer: `CVImageBuffer`
     - maximumBoundingBox: `BoundingBox`
     - frameIndes: `Int`
     */
    private func capturePointCloud(depthData: AVDepthData, videoPixelBuffer: CVImageBuffer, maximumBoundingBox: BoundingBox, frameIndex: Int) {
        
        mesherQueue.async {
            let pointCloud = DepthDataHelper.convertTrueDepthDataToPointCloud(depthData, videoPixelBuffer: videoPixelBuffer, maximumBoundingBox: maximumBoundingBox)
            
            if let pointCloud = pointCloud {
                
                
                self.registeredPointCloud = Mesher().registerPointCloud(newPointCloud: pointCloud, registeredPointCloud: self.registeredPointCloud)
                
                
                if (self.saveCapturedFrame == true) {
                    self.savePointCloud(frame: frameIndex, pointsXYZ: pointCloud.pointsXYZ)
                }
            }
        }
    }
    
    /**
     Clear Captured Point Clouds
     - parameters:
     - None
     */
    private func clearCapturedPointClouds() {
        self.registeredPointCloud = PointCloud()
        self.framecount = 0
        self.lastCaptureTimeInMs = 0
    }
    
    /**
     Clear Mesh
     - parameters:
     - None
     */
    private func clearMesh() {
        mesh = ([], [], [])
    }
    
    /**
     Exports a Scan
     - parameters:
     - fileName:String
     - fileType:FileType {OBJ or PLY}
     - Returns Result File Path.
     */
    public func exportScan(fileName:String, fileType:FileType) -> String? {
#if DEBUG
        print("ScanSessionManager: exporting Scan..")
#endif
        let vertices = mesh.vertices
        let nb_vertices = vertices.count
        
        var color: Array<UInt8> = []
        
        if (mesh.colors.isEmpty) {
            for _ in stride(from: 0, to: nb_vertices, by: 3) {
                color.append(50)
                color.append(50)
                color.append(50)
            }
        } else {
            for item in mesh.colors {
                color.append(item)
            }
        }
        
        
        // set fileName and fileExtension
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileExtension = fileType == .OBJ ? ".obj" : ".ply"
        let filePath = path.first!.path + "/" + fileName + fileExtension
        
        // write File
        
        let faces = mesh.faces
        let success = fileType == .OBJ ? MesherSDK.writeObj(inVert: mesh.vertices, inFaceVertId: faces, inColor: nil, inFileName: filePath) : MesherSDK.writePly(inVert: mesh.vertices, inFaceVertId: faces, inColor: color, inFileName: filePath)
        if success {
            return filePath
        }
        
        return nil
    }
    
    /**
     Compute high resolution mesh
     - parameters:
     - None
     */
    public func computeHighResolutionMesh() {
        self.mesh = Mesher().mesh(self.registeredPointCloud)
    }
    
    
    /**
     Save point cloud
     - parameters:
     - frame: `Int` frame index
     - pointsXYZ: `Array<Float>` XYZ points
     */
    private func savePointCloud(frame: Int, pointsXYZ: Array<Float>) {
        
        var valuesString: String = ""
        
        for i in 0..<(pointsXYZ.count) {
            valuesString += "\(Float(pointsXYZ[i])) "
            if i % 3 == 2 {
                valuesString += "\n"
            }
        }
        
        let fileName = "TrueDepth_Output\(frame).xyz"
        
        var dir: URL?
        
        do {
            try dir = FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            print("error accessing the document directory")
        }
        
        let fileURL = dir!.appendingPathComponent(fileName).path
        
#if DEBUG
        print(fileURL)
#endif
        
        do {
            try valuesString.write(to: URL(fileURLWithPath: fileURL), atomically: false, encoding: .utf8)
        } catch {
            print("error printing")
        }
        
    }
    
}
