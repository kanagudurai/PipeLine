//
//  RotationInfo.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-08-09.
//

import Foundation
import SceneKit

struct RotationInfo: Equatable {
    
    var currentAngleX: Float = 0
    var currentAngleY: Float = 0
    var currentAngleZ: Float = 0
    var pivot: SCNMatrix4 = SCNMatrix4Identity
    var offset: SCNVector3 = SCNVector3Zero
    var transform: SCNMatrix4 = SCNMatrix4Identity
    var maxTranslationDeltaX: Float = 0.4
    var maxTranslationDeltaY: Float = 0.4
    init(currentAngleX: Float = 0,
         currentAngleY: Float = 0,
         currentAngleZ: Float = 0,
         pivot: SCNMatrix4 = SCNMatrix4Identity,
         offset: SCNVector3 = SCNVector3Zero,
         transform: SCNMatrix4 = SCNMatrix4Identity,
         maxTranslationDeltaX: Float = 0.4,
         maxTranslationDeltaY: Float = 0.4) {
        self.currentAngleX = currentAngleX
        self.currentAngleY = currentAngleY
        self.currentAngleZ = currentAngleZ
        self.pivot = pivot
        self.offset = offset
        self.transform = transform
    }
    private var xTranslation: Float = 0
    private var yTranslation: Float = 0

    mutating func translateBy(x: Float, y: Float, z: Float = 0) {
        if abs(x) > 0.02 || abs(y) > 0.02 {
            return
        }
        xTranslation = xTranslation + x
        yTranslation = yTranslation + y
        let newX: Float
        if abs(xTranslation) <= maxTranslationDeltaX {
            newX = x
        } else {
            newX = 0
        }
        let newY: Float
        if abs(yTranslation) <= maxTranslationDeltaY {
            newY = y
        } else {
            newY = 0
        }
        transform = SCNMatrix4Translate(transform, newX, newY, 0)
    }
    
    mutating func translateUp() {
        translateBy(x: 0, y: 0.005)
    }
    
    mutating func translateDown() {
        translateBy(x: 0, y: -0.005)
       
    }
    
    mutating func translateRight() {
        translateBy(x: 0.005, y: 0)
    }
    
    mutating func translateLeft() {
        translateBy(x: -0.005, y: 0)
    }
}

extension SCNMatrix4: Equatable {
    
    public static func == (lhs: SCNMatrix4, rhs: SCNMatrix4) -> Bool {
        SCNMatrix4EqualToMatrix4(lhs, rhs)
    }
    
}
