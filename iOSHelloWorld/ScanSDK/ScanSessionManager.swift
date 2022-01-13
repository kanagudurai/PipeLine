//
//  ScanSessionManager.swift
//  scan-demo
//
//  Created by Melek Ramki on 2021-10-21.
//  Copyright © 2021 Podform3D. All rights reserved.
//

import UIKit
import AVFoundation
import CoreVideo
import MobileCoreServices
import Accelerate

//@available(iOS 15, *)
public class ScanSessionManager: NSObject, AVCaptureDataOutputSynchronizerDelegate {
    
    // MARK: Private properties
    private static var _instance: ScanSessionManager?
    
    private var jetView: PreviewMetalView!
    
    private let session = AVCaptureSession()
    
    private var isSessionRunning = false
    
    /// A DispatchQueue which will Communicate with the session and other session objects on this queue
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], autoreleaseFrequency: .workItem)
    
    /// An AVCaptureDeviceInput which provides media from a capture device to a capture session
    private var videoDeviceInput: AVCaptureDeviceInput!
    
    /// An DispatchQueue which will handle AVCaptureVideoDataOutput
    private let dataOutputQueue = DispatchQueue(label: "video data queue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    /// An AVCaptureVideoDataOutput which will capture output that records video and provides access to video frames for processing
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    /// An AVCaptureDepthDataOutput which will capture output that records scene depth information on compatible camera devices
    private let depthDataOutput = AVCaptureDepthDataOutput()
    
    /// An AVCaptureDataOutputSynchronizer that coordinates time-matched delivery of data from `videoDataOutput` and `depthDataOutput`
    private var outputSynchronizer: AVCaptureDataOutputSynchronizer?
    
    /// Combines video frames and JET depth frames.
    private let videoDepthMixer = VideoMixer()
    
    private let videoDepthConverter = DepthToJETConverter()
    
    private var renderingEnabled = true
    
    /// An DiscoverySession which for finding and monitoring available capture devices.
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera],
                                                                               mediaType: .video,
                                                                               position: .front)
    
    private var statusBarOrientation: UIInterfaceOrientation = .portrait
    
    private var JETEnabled = true
    private var viewFrameSize = CGSize()
    
    private var setupResult: SessionSetupResult = .success
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    /// Initializes the ScanSessionManager, this must be called before ScanSessionManager.get().
    public static func initInstance() {
        //guard _instance == nil else { fatalError("ScanSessionManager is already initialized!") }
        if _instance != nil {
        _instance = nil
        }
        _instance = ScanSessionManager()
    }
    
    /// Returns the ScanSessionManager instance.
    public static func get() -> ScanSessionManager {
        guard let instance = _instance else {
            fatalError("ScanSessionManager.initialize must be called before ScanSDK.get")
        }
        return instance
    }
    
    private override init() {
        super.init()
        // Ask for permissions
        grantCapturePermission()
        // Configure Capture data Session, Only Call this on the session queue
        sessionQueue.async {
            self.configureSession()
            self.depthDataOutput.isFilteringEnabled = false
        }
        // Setup video input, output and add observers
        setupVideoSession()
    }
    
    /**
     Sets the PreviewMetalView for the ScanSessionManager:
     - parameters:
     - jetView:`PreviewMetalView`
     */
    public func setPreviewView(jetView: PreviewMetalView) {
        self.jetView = jetView
    }
    
    // Check video authorization status and asks for permission, video access is required
    private func grantCapturePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant video access
             We suspend the session queue to delay session setup until the access request has completed
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access
            setupResult = .notAuthorized
        }
    }
    
    // MARK: - Session Management
    
    /*
     Setup the capture session.
     In general it is not safe to mutate an AVCaptureSession or any of its
     inputs, outputs, or connections from multiple threads at the same time.
     
     Why not do all of this on the main queue?
     Because AVCaptureSession.startRunning() is a blocking call which can
     take a long time. We dispatch session setup to the sessionQueue so
     that the main queue isn't blocked, which keeps the UI responsive.
     */
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        let defaultVideoDevice: AVCaptureDevice? = videoDeviceDiscoverySession.devices.first
        
        guard let videoDevice = defaultVideoDevice else {
            print("Could not find any video device")
            setupResult = .configurationFailed
            return
        }
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        
        // Add a video input
        guard session.canAddInput(videoDeviceInput) else {
            print("Could not add video device input to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.addInput(videoDeviceInput)
        
        // Add a video data output
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        } else {
            print("Could not add video data output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add a depth data output
        if session.canAddOutput(depthDataOutput) {
            session.addOutput(depthDataOutput)
            depthDataOutput.isFilteringEnabled = false
            if let connection = depthDataOutput.connection(with: .depthData) {
                connection.isEnabled = true
            } else {
                print("No AVCaptureConnection")
            }
        } else {
            print("Could not add depth data output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Search for highest resolution with half-point depth values
        let depthFormats = videoDevice.activeFormat.supportedDepthDataFormats
        let filtered = depthFormats.filter({
            CMFormatDescriptionGetMediaSubType($0.formatDescription) == kCVPixelFormatType_DepthFloat32
        })
        let selectedFormat = filtered.max(by: {
            first, second in CMVideoFormatDescriptionGetDimensions(first.formatDescription).width < CMVideoFormatDescriptionGetDimensions(second.formatDescription).width
        })
        
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.activeDepthDataFormat = selectedFormat
            videoDevice.unlockForConfiguration()
        } catch {
            print("Could not lock device for configuration: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Use an AVCaptureDataOutputSynchronizer to synchronize the video data and depth data outputs.
        // The first output in the dataOutputs array, in this case the AVCaptureVideoDataOutput, is the "master" output.
        outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [videoDataOutput, depthDataOutput])
        outputSynchronizer!.setDelegate(self, queue: dataOutputQueue)
        session.commitConfiguration()
    }
    
    // Setup video input, output and add observers
    private func setupVideoSession() {
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        statusBarOrientation = interfaceOrientation
        
        let initialThermalState = ProcessInfo.processInfo.thermalState
        if initialThermalState == .serious || initialThermalState == .critical {
            showThermalState(state: initialThermalState)
        }
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded
                self.addObservers()
                let videoOrientation = self.videoDataOutput.connection(with: .video)!.videoOrientation
                let videoDevicePosition = self.videoDeviceInput.device.position
                let rotation = PreviewMetalView.Rotation(with: interfaceOrientation,
                                                         videoOrientation: videoOrientation,
                                                         cameraPosition: videoDevicePosition)
                self.jetView.mirroring = (videoDevicePosition == .front)
                if let rotation = rotation {
                    self.jetView.rotation = rotation
                }
                self.dataOutputQueue.async {
                    self.renderingEnabled = true
                }
                
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let message = NSLocalizedString("TrueDepthStreamer doesn't have permission to use the camera, please change privacy settings",
                                                    comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "TrueDepthStreamer", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                            style: .`default`,
                                                            handler: { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                  options: [:],
                                                  completionHandler: nil)
                    }))
                    // self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                return
            }
        }
    }
    
    // You can use this opportunity to take corrective action to help cool the system down.
    @objc
    func thermalStateChanged(notification: NSNotification) {
        if let processInfo = notification.object as? ProcessInfo {
            showThermalState(state: processInfo.thermalState)
        }
    }
    
    func showThermalState(state: ProcessInfo.ThermalState) {
        DispatchQueue.main.async {
            var thermalStateString = "UNKNOWN"
            if state == .nominal {
                thermalStateString = "NOMINAL"
            } else if state == .fair {
                thermalStateString = "FAIR"
            } else if state == .serious {
                thermalStateString = "SERIOUS"
            } else if state == .critical {
                thermalStateString = "CRITICAL"
            }
            
            let message = NSLocalizedString("Thermal state: \(thermalStateString)", comment: "Alert message when thermal state has changed")
            let alertController = UIAlertController(title: "TrueDepthStreamer", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
            // TODO: PF3D-11 Add delegate and handle view changes
            // self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - KVO and Notifications
    
    private var sessionRunningContext = 0
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(thermalStateChanged),
                                               name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError),
                                               name: NSNotification.Name.AVCaptureSessionRuntimeError, object: session)
        
        session.addObserver(self, forKeyPath: "running", options: NSKeyValueObservingOptions.new, context: &sessionRunningContext)
        
        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted),
                                               name: NSNotification.Name.AVCaptureSessionWasInterrupted,
                                               object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange),
                                               name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoDeviceInput.device)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        session.removeObserver(self, forKeyPath: "running", context: &sessionRunningContext)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if context != &sessionRunningContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @objc
    func didEnterBackground(notification: NSNotification) {
        // Free up resources
        dataOutputQueue.async {
            self.renderingEnabled = false
            self.jetView.pixelBuffer = nil
            self.jetView.flushTextureCache()
        }
    }
    
    @objc
    func willEnterForground(notification: NSNotification) {
        dataOutputQueue.async {
            self.renderingEnabled = true
        }
    }
    
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode,
                       exposureMode: AVCaptureDevice.ExposureMode,
                       at devicePoint: CGPoint,
                       monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            let videoDevice = self.videoDeviceInput.device
            
            do {
                try videoDevice.lockForConfiguration()
                if videoDevice.isFocusPointOfInterestSupported && videoDevice.isFocusModeSupported(focusMode) {
                    videoDevice.focusPointOfInterest = devicePoint
                    videoDevice.focusMode = focusMode
                }
                
                if videoDevice.isExposurePointOfInterestSupported && videoDevice.isExposureModeSupported(exposureMode) {
                    videoDevice.exposurePointOfInterest = devicePoint
                    videoDevice.exposureMode = exposureMode
                }
                
                videoDevice.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                videoDevice.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        // In iOS 9 and later, the userInfo dictionary contains information on why the session was interrupted.
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
        }
    }
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error)")
        
        /*
         Automatically try to restart the session running if media services were
         reset and the last start running succeeded. Otherwise, enable the user
         to try to resume the session running.
         */
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    // MARK: AVCaptureDataOutputSynchronizerDelegate: Video + Depth Frame Processing
    
    public func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
        
        if !renderingEnabled {
            return
        }
        
        // Read all outputs
        guard renderingEnabled,
              let syncedDepthData: AVCaptureSynchronizedDepthData =
                synchronizedDataCollection.synchronizedData(for: depthDataOutput) as? AVCaptureSynchronizedDepthData,
              let syncedVideoData: AVCaptureSynchronizedSampleBufferData =
                synchronizedDataCollection.synchronizedData(for: videoDataOutput) as? AVCaptureSynchronizedSampleBufferData else {
                    // only work on synced pairs
                    return
                }
        
        if syncedDepthData.depthDataWasDropped || syncedVideoData.sampleBufferWasDropped {
            return
        }
        
        let sampleBuffer = syncedVideoData.sampleBuffer
        guard let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
                  return
              }
        
        // depth data
        let depthData = syncedDepthData.depthData
        let depthPixelBuffer = depthData.depthDataMap
        
        // Process depth frame
        ScanSDK.get().processDepthFrame(depthData: depthData, videoPixelBuffer: videoPixelBuffer)
        
        // Update JET preview
        if JETEnabled {
            if !videoDepthConverter.isPrepared {
                /*
                 outputRetainedBufferCountHint is the number of pixel buffers we expect to hold on to from the renderer.
                 This value informs the renderer how to size its buffer pool and how many pixel buffers to preallocate. Allow 2 frames of latency
                 to cover the dispatch_async call.
                 */
                var depthFormatDescription: CMFormatDescription?
                CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                             imageBuffer: depthPixelBuffer,
                                                             formatDescriptionOut: &depthFormatDescription)
                videoDepthConverter.prepare(with: depthFormatDescription!, outputRetainedBufferCountHint: 2)
            }
            
            guard let jetPixelBuffer = videoDepthConverter.render(pixelBuffer: depthPixelBuffer, maxDepth: ScanSDK.get().maximumBoundingBox.z) else {
                print("Unable to process depth")
                return
            }
            
            if !videoDepthMixer.isPrepared {
                videoDepthMixer.prepare(with: formatDescription, outputRetainedBufferCountHint: 3)
            }
            
            // Mix the video buffer with the last depth data we received
            guard let mixedBuffer = videoDepthMixer.mix(videoPixelBuffer: videoPixelBuffer, depthPixelBuffer: jetPixelBuffer) else {
                print("Unable to combine video and depth")
                return
            }
            
            jetView.pixelBuffer = mixedBuffer
        }
    }
}
