/*
 * Copyright (C) 2005-2025 Apple Inc. All rights reserved.
 * Copyright (C) 2016-2020 Google Inc. All rights reserved.
 * Copyright (C) 2009 Torch Mobile, Inc.
 * Copyright (C) 2025 Jonathan Wight
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import simd

public struct TransformComponents: Sendable, Equatable {
    public var perspective: SIMD4<Float>
    public var translate: SIMD3<Float>
    public var scale: SIMD3<Float>
    public var skew: Skew
    public var rotation: simd_quatf

    public init(perspective: SIMD4<Float>, translate: SIMD3<Float>, scale: SIMD3<Float>, skew: Skew, rotation: simd_quatf) {
        self.perspective = perspective
        self.translate = translate
        self.scale = scale
        self.skew = skew
        self.rotation = rotation
    }

    static let identity = Self(
        perspective: [0, 0, 0, 1],
        translate: .zero,
        scale: .one,
        skew: Skew.zero,
        rotation: .identity
    )
}

struct Euler {
    enum Order {
        case zyx
    }

    var order: Order = .zyx
    var roll: Float
    var pitch: Float
    var yaw: Float
}

extension Euler {
    init(_ q: simd_quatf) {
        /// Converts a quaternion to Euler angles in radians (yaw, pitch, roll)
        /// Order: ZYX = Yaw (Z), Pitch (Y), Roll (X)
        let x = q.imag.x
        let y = q.imag.y
        let z = q.imag.z
        let w = q.real

        // Roll (x-axis rotation)
        let sinr_cosp = 2 * (w * x + y * z)
        let cosr_cosp = 1 - 2 * (x * x + y * y)
        roll = atan2(sinr_cosp, cosr_cosp)

        // Pitch (y-axis rotation)
        let sinp = 2 * (w * y - z * x)
        if abs(sinp) >= 1 {
            pitch = copysign(.pi / 2, sinp) // use 90 degrees if out of range
        } else {
            pitch = asin(sinp)
        }

        // Yaw (z-axis rotation)
        let siny_cosp = 2 * (w * z + x * y)
        let cosy_cosp = 1 - 2 * (y * y + z * z)
        yaw = atan2(siny_cosp, cosy_cosp)
    }
}

public struct Skew: Sendable, Equatable {
    public var xy: Float
    public var xz: Float
    public var yz: Float

    public init(xy: Float, xz: Float, yz: Float) {
        self.xy = xy
        self.xz = xz
        self.yz = yz
    }

    public static let zero = Self(xy: 0, xz: 0, yz: 0)
}

public extension float4x4 {
    /// Decomposes a 4x4 transformation matrix into its constituent components.
    ///
    /// This implementation is based on the WebKit TransformationMatrix decomposition algorithm.
    ///
    /// - Important: Negative scale values are not preserved during decomposition. When the algorithm
    ///   detects a coordinate system flip (negative determinant indicating an odd number of negative
    ///   scale factors), it normalizes all scale values to be positive and adjusts the rotation
    ///   accordingly. This is a mathematical limitation where negative scale and rotation transformations
    ///   are ambiguous - the same visual result can be achieved with positive scales and different rotations.
    ///
    /// - Returns: A `TransformComponents` structure containing the decomposed perspective, translation,
    ///   scale (always positive), skew, and rotation components, or `nil` if the matrix cannot be decomposed.
    ///
    /// - Note: If you need to preserve negative scale information, you should track it separately before
    ///   decomposition or use an alternative approach that explicitly handles reflections.
    ///
    /// From: https://github.com/WebKit/WebKit/blob/8a14a6497b6d24b319ee5c034575190a352adb8f/Source/WebCore/platform/graphics/transforms/TransformationMatrix.cpp#L560
    var decompose: TransformComponents? {
        var result = TransformComponents.identity

        var localMatrix = self

        // Normalize the matrix.
        if localMatrix[3][3] == 0 {
            return nil
        }

        let scale = localMatrix[3][3]
        localMatrix[0] /= scale
        localMatrix[1] /= scale
        localMatrix[2] /= scale
        localMatrix[3] /= scale

        // perspectiveMatrix is used to solve for perspective, but it also provides
        // an easy way to test for singularity of the upper 3x3 component.
        let perspectiveMatrix = float4x4(
            SIMD4<Float>(localMatrix[0].xyz, 0),
            SIMD4<Float>(localMatrix[1].xyz, 0),
            SIMD4<Float>(localMatrix[2].xyz, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )

        if !perspectiveMatrix.determinant.isNormal {
            return nil
        }

        // First, isolate perspective. This is the messiest.
        if localMatrix[0][3] != 0 || localMatrix[1][3] != 0 || localMatrix[2][3] != 0 {
            // rightHandSide is the right hand side of the equation.
            let rightHandSide = SIMD4<Float>(
                localMatrix[0][3],
                localMatrix[1][3],
                localMatrix[2][3],
                localMatrix[3][3]
            )

            // Solve the equation by inverting perspectiveMatrix and multiplying
            // rightHandSide by the inverse. (This is the easiest way, not
            // necessarily the best.)
            let inversePerspectiveMatrix = perspectiveMatrix.inverse
            let transposedInversePerspectiveMatrix = inversePerspectiveMatrix.transpose

            result.perspective = transposedInversePerspectiveMatrix * rightHandSide

            // Clear the perspective partition
            localMatrix[0][3] = 0
            localMatrix[1][3] = 0
            localMatrix[2][3] = 0
            localMatrix[3][3] = 1
        } else {
            // No perspective.
            result.perspective = [0, 0, 0, 1]
        }

        // Next take care of translation (easy).
        result.translate = localMatrix[3].xyz

        localMatrix[3].xyz = .zero

        // Note: Deviating from the spec in terms of variable naming. The matrix is
        // stored on column major order and not row major. Using the variable 'row'
        // instead of 'column' in the spec pseudocode has been the source of
        // confusion, specifically in sorting out rotations.

        // Now get scale and shear.
        var column = float3x3(
            localMatrix[0].xyz,
            localMatrix[1].xyz,
            localMatrix[2].xyz
        )

        // Compute X scale factor and normalize the first column.
        result.scale.x = length(column[0])

        column[0].scale(to: 1.0)

        // Compute XY shear factor and make 2nd column orthogonal to 1st.
        result.skew.xy = dot(column[0], column[1])
        column[1] = column[1] * 1.0 + column[0] * -result.skew.xy

        // Now, compute Y scale and normalize 2nd column.
        result.scale.y = length(column[1])
        column[1].scale(to: 1.0)
        result.skew.xy /= result.scale.y

        // Compute XZ and YZ shears, orthogonalize 3rd column.
        result.skew.xz = dot(column[0], column[2])
        column[2] = column[2] * 1.0 + column[0] * -result.skew.xz
        result.skew.yz = dot(column[1], column[2])
        column[2] = column[2] * 1.0 + column[1] * -result.skew.yz

        // Next, get Z scale and normalize 3rd column.
        result.scale.z = length(column[2])
        column[2].scale(to: 1.0)
        result.skew.xz /= result.scale.z
        result.skew.yz /= result.scale.z

        // At this point, the matrix (in column[]) is orthonormal.
        // Check for a coordinate system flip. If the determinant
        // is -1, then negate the matrix and the scaling factors.
        // This handles cases where there's an odd number of negative scales,
        // but note that the original negative scale values are not preserved -
        // they are normalized to positive values with adjusted rotation.
        let pdum3 = cross(column[1], column[2])

        if dot(column[0], pdum3) < 0 {
            result.scale *= -1
            column *= -1
        }

        // Lastly, compute the quaternions.
        // See https://en.wikipedia.org/wiki/Rotation_matrix#Quaternion.
        // Note: deviating from spec (http://www.w3.org/TR/css3-transforms/)
        // which has a degenerate case when the trace (t) of the orthonormal matrix
        // (Q) approaches -1. In the Wikipedia article, Q_ij is indexing on row then
        // column. Thus, Q_ij = column[j][i].

        // The following are equivalent represnetations of the rotation matrix:
        //
        // Axis-angle form:
        //
        //      [ c+(1-c)x^2  (1-c)xy-sz  (1-c)xz+sy ]    c = cos theta
        // R =  [ (1-c)xy+sz  c+(1-c)y^2  (1-c)yz-sx ]    s = sin theta
        //      [ (1-c)xz-sy  (1-c)yz+sx  c+(1-c)z^2 ]    [x,y,z] = axis or rotation
        //
        // The sum of the diagonal elements (trace) is a simple function of the cosine
        // of the angle. The w component of the quaternion is cos(theta/2), and we
        // make use of the double angle formula to directly compute w from the
        // trace. Differences between pairs of skew symmetric elements in this matrix
        // isolate the remaining components. Since w can be zero (also numerically
        // unstable if near zero), we cannot rely solely on this approach to compute
        // the quaternion components.
        //
        // Quaternion form:
        //
        //       [ 1-2(y^2+z^2)    2(xy-zw)      2(xz+yw)   ]
        //  r =  [   2(xy+zw)    1-2(x^2+z^2)    2(yz-xw)   ]    q = (x,y,y,w)
        //       [   2(xz-yw)      2(yz+xw)    1-2(x^2+y^2) ]
        //
        // Different linear combinations of the diagonal elements isolates x, y or z.
        // Sums or differences between skew symmetric elements isolate the remainder.

        let t = column[0][0] + column[1][1] + column[2][2]

        let rotation: SIMD4<Float>

        // https://en.wikipedia.org/wiki/Rotation_matrix#Quaternion
        if 1 + t > 0.001 {
            // Numerically stable as long as 1+t is not close to zero. Otherwise use the
            // diagonal element with the greatest value to compute the quaternions.
            let r = sqrt(1.0 + t)
            let s = 0.5 / r
            rotation = SIMD4<Float>(
                (column[1][2] - column[2][1]) * s,
                (column[2][0] - column[0][2]) * s,
                (column[0][1] - column[1][0]) * s,
                0.5 * r
            )
        } else if column[0][0] > column[1][1], column[0][0] > column[2][2] {
            // Q_xx is largest.
            let r = sqrt(1.0 + column[0][0] - column[1][1] - column[2][2])
            let s = 0.5 / r
            rotation = SIMD4<Float>(
                0.5 * r,
                (column[1][0] - column[0][1]) * s,
                (column[2][0] + column[0][2]) * s,
                (column[1][2] - column[2][1]) * s
            )
        } else if column[1][1] > column[2][2] {
            // Q_yy is largest.
            let r = sqrt(1.0 - column[0][0] + column[1][1] - column[2][2])
            let s = 0.5 / r
            rotation = SIMD4<Float>(
                (column[1][0] + column[0][1]) * s,
                0.5 * r,
                (column[2][1] + column[1][2]) * s,
                (column[2][0] - column[0][2]) * s
            )
        } else {
            // Q_zz is largest.
            let r = sqrt(1.0 - column[0][0] - column[1][1] + column[2][2])
            let s = 0.5 / r
            rotation = SIMD4<Float>(
                (column[2][0] + column[0][2]) * s,
                (column[2][1] + column[1][2]) * s,
                0.5 * r,
                (column[0][1] - column[1][0]) * s
            )
        }

        result.rotation = .init(vector: rotation)
        return result
    }
}

extension SIMD3<Float> {
    mutating func scale(to desiredLength: Float) {
        let currentLength = length(self)
        if currentLength != 0 {
            self *= desiredLength / currentLength
        }
    }
}
