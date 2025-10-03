import Foundation
import simd
import SwiftUI

public struct CameraCone: Sendable, Equatable {
    public var parameters: CameraConeParameters
    public var rotation: Angle
    public var height: Float

    public init(parameters: CameraConeParameters, rotation: Angle, height: Float) {
        self.parameters = parameters
        self.rotation = rotation
        self.height = height
    }

    public var cameraTransform: float4x4 {
        parameters.cameraMatrix(angle: Float(rotation.radians), t: height)
    }
}

/// Defines a truncated cone with a camera that orbits around it
public struct CameraConeParameters: Sendable, Equatable, Codable {
    /// The center point of circle A
    public var centerA: SIMD3<Float>

    /// Radius of circle A
    public var radiusA: Float

    /// Radius of circle B
    public var radiusB: Float

    /// The axis direction from circle A to circle B (normalized)
    public var axis: SIMD3<Float>

    /// Distance between circle A and circle B along the axis
    public var distance: Float

    public init(centerA: SIMD3<Float>, radiusA: Float, radiusB: Float, axis: SIMD3<Float>, distance: Float) {
        self.centerA = centerA
        self.radiusA = radiusA
        self.radiusB = radiusB
        self.axis = normalize(axis)
        self.distance = distance
    }

    /// Initialize with two center points instead of axis and distance
    public init(centerA: SIMD3<Float>, centerB: SIMD3<Float>, radiusA: Float, radiusB: Float) {
        self.centerA = centerA
        self.radiusA = radiusA
        self.radiusB = radiusB
        let delta = centerB - centerA
        self.distance = length(delta)
        self.axis = self.distance > 0 ? normalize(delta) : SIMD3<Float>(0, 1, 0)
    }
}

public extension CameraConeParameters {
    /// The center point of circle B (computed from centerA, axis, and distance)
    var centerB: SIMD3<Float> {
        centerA + axis * distance
    }

    func cameraPosition(angle: Float, t: Float) -> SIMD3<Float> {
        let t = max(0, min(1, t))

        // Position along cone axis
        let cameraDistance = distance * t
        let currentRadius = radiusA + (radiusB - radiusA) * t
        let centerA = self.centerA
        let coneCenterAtPosition = centerA + axis * cameraDistance

        // Choose an arbitrary vector perpendicular to axis
        let arbitrary = abs(axis.y) == 1 ? SIMD3<Float>(0, 0, 1) : SIMD3<Float>(0, 1, 0)
        let baseVector = normalize(cross(axis, arbitrary)) * currentRadius

        // Rotate baseVector around the axis by the angle using a quaternion
        let rotation = simd_quatf(angle: angle, axis: -axis)
        let offset = rotation.act(baseVector)

        // Final camera position
        return coneCenterAtPosition + offset
    }

    func eyePosition(angle _: Float, t _: Float) -> SIMD3<Float> {
        centerA
    }

    func cameraMatrix(angle: Float, t: Float, up: SIMD3<Float> = [0, 1, 0]) -> float4x4 {
        let cameraPosition = self.cameraPosition(angle: angle, t: t)
        let eyePosition = self.eyePosition(angle: angle, t: t)
        return LookAt(position: cameraPosition, target: eyePosition, up: up).cameraMatrix
    }
}
