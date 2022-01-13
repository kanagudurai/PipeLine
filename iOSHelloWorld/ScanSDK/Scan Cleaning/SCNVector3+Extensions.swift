/*
 * Copyright (c) 2013-2014 Kim Pedersen
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import SceneKit

extension SCNVector3 {
    /**
     * Negates the vector described by SCNVector3 and returns
     * the result as a new SCNVector3.
     */
    func negate() -> SCNVector3 {
        return self * -1
    }

    /**
     * Negates the vector described by SCNVector3
     */
    mutating func negated() -> SCNVector3 {
        self = negate()
        return self
    }

    /**
     * Returns the length (magnitude) of the vector described by the SCNVector3
     */
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }

    /**
     * Normalizes the vector described by the SCNVector3 to length 1.0 and returns
     * the result as a new SCNVector3.
     */
    var normalized: SCNVector3 {
        return self / length()
    }

    /**
     * Normalizes the vector described by the SCNVector3 to length 1.0.
     */
    mutating func normalize() -> SCNVector3 {
        self = normalized
        return self
    }

    /**
     * Calculates the distance between two SCNVector3. Pythagoras!
     */
    func distance(vector: SCNVector3) -> Float {
        return (self - vector).length()
    }

    /**
     * Calculates the dot product between two SCNVector3.
     */
    func dot(vector: SCNVector3) -> Float {
        return x * vector.x + y * vector.y + z * vector.z
    }

    /**
     * Calculates the cross product between two SCNVector3.
     */
    func cross(vector: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(y * vector.z - z * vector.y, z * vector.x - x * vector.z, x * vector.y - y * vector.x)
    }


    /**
     * Adds two SCNVector3 vectors and returns the result as a new SCNVector3.
     */
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    }

    /**
     * Increments a SCNVector3 with the value of another.
     */
    static func += ( left: inout SCNVector3, right: SCNVector3) {
        left = left + right
    }

    /**
     * Subtracts two SCNVector3 vectors and returns the result as a new SCNVector3.
     */
    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
    }

    /**
     * Decrements a SCNVector3 with the value of another.
     */
    static func -= ( left: inout SCNVector3, right: SCNVector3) {
        left = left - right
    }

    /**
     * Multiplies two SCNVector3 vectors and returns the result as a new SCNVector3.
     */
    static func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
    }

    /**
     * Multiplies a SCNVector3 with another.
     */
    static func *= ( left: inout SCNVector3, right: SCNVector3) {
        left = left * right
    }

    /**
     * Multiplies the x, y and z fields of a SCNVector3 with the same scalar value and
     * returns the result as a new SCNVector3.
     */
    static func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }

    /**
     * Multiplies the x and y fields of a SCNVector3 with the same scalar value.
     */
    static func *= (vector: inout SCNVector3, scalar: Float) {
        vector = vector * scalar
    }

    /**
     * Divides two SCNVector3 vectors abd returns the result as a new SCNVector3
     */
    static func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
    }

    /**
     * Divides a SCNVector3 by another.
     */
    static func /= ( left: inout SCNVector3, right: SCNVector3) {
        left = left / right
    }

    /**
     * Divides the x, y and z fields of a SCNVector3 by the same scalar value and
     * returns the result as a new SCNVector3.
     */
    static func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
    }

    /**
     * Divides the x, y and z of a SCNVector3 by the same scalar value.
     */
    static func /= ( vector: inout SCNVector3, scalar: Float) {
        vector = vector / scalar
    }

    /**
     * Negate a vector
     */
    static func SCNVector3Negate(vector: SCNVector3) -> SCNVector3 {
        return vector * -1
    }

    /**
     * Returns the length (magnitude) of the vector described by the SCNVector3
     */
    static func SCNVector3Length(vector: SCNVector3) -> Float {
        return sqrtf(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z)
    }

    /**
     * Returns the distance between two SCNVector3 vectors
     */
    static func SCNVector3Distance(vectorStart: SCNVector3, vectorEnd: SCNVector3) -> Float {
        return SCNVector3Length(vector: vectorEnd - vectorStart)
    }

    /**
     * Returns the distance between two SCNVector3 vectors
     */
    static func SCNVector3Normalize(vector: SCNVector3) -> SCNVector3 {
        return vector / SCNVector3Length(vector: vector)
    }

    /**
     * Calculates the dot product between two SCNVector3 vectors
     */
    static func SCNVector3DotProduct(left: SCNVector3, right: SCNVector3) -> Float {
        return left.x * right.x + left.y * right.y + left.z * right.z
    }

    /**
     * Calculates the cross product between two SCNVector3 vectors
     */
    static func SCNVector3CrossProduct(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.y * right.z - left.z * right.y, left.z * right.x - left.x * right.z, left.x * right.y - left.y * right.x)
    }

    /**
     * Calculates the SCNVector from lerping between two SCNVector3 vectors
     */
    static func SCNVector3Lerp(vectorStart: SCNVector3, vectorEnd: SCNVector3, t: Float) -> SCNVector3 {
        return SCNVector3Make(vectorStart.x + ((vectorEnd.x - vectorStart.x) * t), vectorStart.y + ((vectorEnd.y - vectorStart.y) * t), vectorStart.z + ((vectorEnd.z - vectorStart.z) * t))
    }

    /**
     * Project the vector, vectorToProject, onto the vector, projectionVector.
     */
    static func SCNVector3Project(vectorToProject: SCNVector3, projectionVector: SCNVector3) -> SCNVector3 {
        let scale: Float = SCNVector3DotProduct(left: projectionVector, right: vectorToProject) / SCNVector3DotProduct(left: projectionVector, right: projectionVector)
        let v: SCNVector3 = projectionVector * scale
        return v
    }
}

extension SCNVector3:Hashable {
    
    public func hash(into hasher: inout Hasher) {
        "\(x)\(y)\(z)"
            .hash(into: &hasher)
    }

}


extension SCNVector3:Equatable {

    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
         lhs.x == rhs.x &&
            lhs.y == rhs.y &&
            lhs.z == rhs.z
    }

}

class SCNUtils {

    // Return the normal against the plane defined by the 3 vertices, specified in
    // counter-clockwise order.
    // note, this is an un-normalized normal.  (ha.. wtf? yah, thats right)
    class func getNormal(v0: SCNVector3, v1: SCNVector3, v2: SCNVector3) -> SCNVector3 {
        // there are three edges defined by these 3 vertices, but we only need 2 to define the plane
        let edgev0v1 = v1 - v0
        let edgev1v2 = v2 - v1

        // Assume the verts are expressed in counter-clockwise order to determine normal
        return edgev0v1.cross(vector: edgev1v2)
    }
}

// The following SCNVector3 extension comes from https://github.com/devindazzle/SCNVector3Extensions - with some changes by me
extension SCNVector3 {
    func angle(between vector: SCNVector3) -> CGFloat {
        // angle between 3d vectors P and Q is equal to the arc cos of their dot products over the product of
        // their magnitudes (lengths).
        //    theta = arccos( (P • Q) / (|P||Q|) )
        let dp = dot(vector: vector) // dot product
        let magProduct = length() * vector.length() // product of lengths (magnitudes)
        return CGFloat(acos(dp / magProduct)) // DONE
    }
//    /**
//    * Negates the vector described by SCNVector3 and returns
//    * the result as a new SCNVector3.
//    */
//    func negate() -> SCNVector3 {
//        return self * -1
//    }
//
//    /**
//    * Negates the vector described by SCNVector3
//    */
//    mutating func negated() -> SCNVector3 {
//        self = negate()
//        return self
//    }
//
//    /**
//    * Returns the length (magnitude) of the vector described by the SCNVector3
//    */
//    func length() -> CGFloat {
//        return sqrt(x*x + y*y + z*z)
//    }
//
//    /**
//    * Normalizes the vector described by the SCNVector3 to length 1.0 and returns
//    * the result as a new SCNVector3.
//    */
//    func normalized() -> SCNVector3? {
//
//        var len = length()
//        if(len > 0)
//        {
//            return self / length()
//        }
//        else
//        {
//            return nil
//        }
//    }
//
//    /**
//    * Normalizes the vector described by the SCNVector3 to length 1.0.
//    */
//    mutating func normalize() -> SCNVector3? {
//        if let vn = normalized()
//        {
//            self = vn
//            return self
//        }
//        return nil
//    }
//
//    mutating func normalizeOrZ() -> SCNVector3 {
//        if let vn = normalized()
//        {
//            self = vn
//            return self
//        }
//        return SCNVector3()
//    }

//    /**
//    * Calculates the distance between two SCNVector3. Pythagoras!
//    */
//    func distance(vector: SCNVector3) -> CGFloat {
//        return (self - vector).length()
//    }
//
//    /**
//    * Calculates the dot product between two SCNVector3.
//    */
//    func dot(vector: SCNVector3) -> CGFloat {
//        return x * vector.x + y * vector.y + z * vector.z
//    }
//
//    /**
//    * Calculates the cross product between two SCNVector3.
//    */
//    func cross(vector: SCNVector3) -> SCNVector3 {
//        return SCNVector3Make(y * vector.z - z * vector.y, z * vector.x - x * vector.z, x * vector.y - y * vector.x)
//    }
//
//    func angle(vector: SCNVector3) -> CGFloat
//    {
//        // angle between 3d vectors P and Q is equal to the arc cos of their dot products over the product of
//        // their magnitudes (lengths).
//        //    theta = arccos( (P • Q) / (|P||Q|) )
//        let dp = dot(vector) // dot product
//        let magProduct = length() * vector.length() // product of lengths (magnitudes)
//        return acos(dp / magProduct) // DONE
//    }

    // Constrains (or reposition) this vector to fall within the specified min and max vectors.
    // Note - this assumes the max vector points to the outer-most corner (farthest from origin) while the
    // min vector represents the inner-most corner of the valid constraint space
    mutating func constrain(min: SCNVector3, max: SCNVector3) -> SCNVector3 {
        if(x < min.x) { self.x = min.x }
        if(x > max.x) { self.x = max.x }

        if(y < min.y) { self.y = min.y }
        if(y > max.y) { self.y = max.y }

        if(z < min.z) { self.z = min.z }
        if(z > max.z) { self.z = max.z }

        return self
    }

    var vector4: SCNVector4 {
        return SCNVector4(x:x, y:y, z:z, w:1)
    }

    func transformed(by matrix: SCNMatrix4) -> SCNVector3 {
        let transformedVector =  matrix * vector4
        return transformedVector.homogenized
    }

    static func * (vector: SCNVector3, matrix: SCNMatrix4) -> SCNVector3 {
        let newVector = vector.vector4 * matrix
        return SCNVector3(x:newVector.x, y:newVector.y, z:newVector.z)
    }


    static func * (matrix: SCNMatrix4, vector: SCNVector3) -> SCNVector3 {
        let newVector = matrix * vector.vector4
        return SCNVector3(x:newVector.x, y:newVector.y, z:newVector.z)
    }
}

extension SCNVector4 {

    static func * (vector: SCNVector4, matrix: SCNMatrix4) -> SCNVector4 {
        let x = matrix.m11 * vector.x + matrix.m21 * vector.y + matrix.m31 * vector.z + matrix.m41 * vector.w
        let y = matrix.m12 * vector.x + matrix.m22 * vector.y + matrix.m32 * vector.z + matrix.m42 * vector.w
        let z = matrix.m13 * vector.x + matrix.m23 * vector.y + matrix.m33 * vector.z + matrix.m43 * vector.w
        let w = matrix.m14 * vector.x + matrix.m24 * vector.y + matrix.m34 * vector.z + matrix.m44 * vector.w
        return SCNVector4(x:x, y:y, z:z, w:w)
    }


    static func  * (matrix: SCNMatrix4, vector: SCNVector4) -> SCNVector4 {
        let x = matrix.m11 * vector.x + matrix.m12 * vector.y + matrix.m13 * vector.z + matrix.m14 * vector.w
        let y = matrix.m21 * vector.x + matrix.m22 * vector.y + matrix.m23 * vector.z + matrix.m24 * vector.w
        let z = matrix.m31 * vector.x + matrix.m32 * vector.y + matrix.m33 * vector.z + matrix.m34 * vector.w
        let w = matrix.m41 * vector.x + matrix.m42 * vector.y + matrix.m43 * vector.z + matrix.m44 * vector.w
        return SCNVector4(x:x, y:y, z:z, w:w)
    }


    var homogenized: SCNVector3 {
        return SCNVector3(x:x/w, y:y/w, z:z/w)
    }
}

extension SCNMatrix4 {

}


//
///**
//* Adds two SCNVector3 vectors and returns the result as a new SCNVector3.
//*/
//func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
//    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
//}
//
///**
//* Increments a SCNVector3 with the value of another.
//*/
//func += (inout left: SCNVector3, right: SCNVector3) {
//    left = left + right
//}
//
///**
//* Subtracts two SCNVector3 vectors and returns the result as a new SCNVector3.
//*/
//func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
//    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
//}
//
///**
//* Decrements a SCNVector3 with the value of another.
//*/
//func -= (inout left: SCNVector3, right: SCNVector3) {
//    left = left - right
//}

///**
//* Multiplies two SCNVector3 vectors and returns the result as a new SCNVector3.
//*/
//func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
//    return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
//}

/**
* Multiplies a SCNVector3 with another.
*/
func *= ( left: inout SCNVector3, right: SCNVector3) {
    left = left * right
}

///**
//* Multiplies the x, y and z fields of a SCNVector3 with the same scalar value and
//* returns the result as a new SCNVector3.
//*/
//func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
//    return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
//}

/**
* Multiplies the x and y fields of a SCNVector3 with the same scalar value.
*/
func *= ( vector: inout SCNVector3, scalar: Float) {
    vector = vector * scalar
}
////
///**
//* Divides two SCNVector3 vectors abd returns the result as a new SCNVector3
//*/
//func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
//    return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
//}
//
///**
//* Divides a SCNVector3 by another.
//*/
//func /= ( left: inout SCNVector3, right: SCNVector3) {
//    left = left / right
//}
//
///**
//* Divides the x, y and z fields of a SCNVector3 by the same scalar value and
//* returns the result as a new SCNVector3.
//*/
//func / (vector: SCNVector3, scalar: CGFloat) -> SCNVector3 {
//    return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
//}
//
///**
//* Divides the x, y and z of a SCNVector3 by the same scalar value.
//*/
//func /= ( vector: inout SCNVector3, scalar: CGFloat) {
//    vector = vector / scalar
//}
//
///**
//* Calculates the SCNVector from lerping between two SCNVector3 vectors
//*/
//func SCNVector3Lerp(vectorStart: SCNVector3, vectorEnd: SCNVector3, t: CGFloat) -> SCNVector3 {
//    return SCNVector3Make(vectorStart.x + ((vectorEnd.x - vectorStart.x) * t), vectorStart.y + ((vectorEnd.y - vectorStart.y) * t), vectorStart.z + ((vectorEnd.z - vectorStart.z) * t))
//}
//
///**
//* Project the vector, vectorToProject, onto the vector, projectionVector.
//*/
//func SCNVector3Project(vectorToProject: SCNVector3, projectionVector: SCNVector3) -> SCNVector3 {
//    let scale: CGFloat = projectionVector.dot(vectorToProject) / projectionVector.dot(projectionVector)
//    let v: SCNVector3 = projectionVector * scale
//    return v
//}
//


//extension SCNNode {
////    func boundingBoxContains(point: SCNVector3, in node: SCNNode) -> Bool {
////        let localPoint = self.convertPosition(point, from: node)
////        return boundingBoxContains(point: localPoint)
////    }
//
//    func boundingBoxContains(point: SCNVector3) -> Bool {
//        return BoundingBox(self.boundingBox).contains(point)
//    }
//}

//struct BoundingBox {
//    let min: SCNVector3
//    let max: SCNVector3
//
//    var origin: SCNVector3 {
//        return (max - min) * 0.5
//    }
//
//    init(box: (min: SCNVector3, max: SCNVector3)) {
//        min = box.min
//        max = box.max
//    }
//
//    func contains(_ point: SCNVector3) -> Bool {
//        let contains =
//            min.x <= point.x &&
//                min.y <= point.y &&
//                min.z <= point.z &&
//                max.x > point.x &&
//                max.y > point.y &&
//                max.z > point.z
//
//        return contains
//    }
//
//    var coordinateSystem: CoordinateSystem {
//        return CoordinateSystem(xAxis: SCNVector3(x:1, y:0, z:0),
//                                yAxis: SCNVector3(x:0, y:1, z:0),
//                                zAxis: SCNVector3(x:0, y:0, z:1),
//                                origin: origin)
//    }
//}
