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
    public var centerA: SIMD3<Float>

    public var radiusA: Float

    public var radiusB: Float

    /// Unit vector from circle A to circle B.
    public var axis: SIMD3<Float>

    public var distance: Float

    public init(centerA: SIMD3<Float>, radiusA: Float, radiusB: Float, axis: SIMD3<Float>, distance: Float) {
        self.centerA = centerA
        self.radiusA = radiusA
        self.radiusB = radiusB
        self.axis = normalize(axis)
        self.distance = distance
    }

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
    var centerB: SIMD3<Float> {
        centerA + axis * distance
    }

    func cameraPosition(angle: Float, t: Float) -> SIMD3<Float> {
        let t = max(0, min(1, t))

        let cameraDistance = distance * t
        let currentRadius = radiusA + (radiusB - radiusA) * t
        let centerA = self.centerA
        let coneCenterAtPosition = centerA + axis * cameraDistance

        let baseVector = perpendicular(to: axis) * currentRadius

        let rotation = simd_quatf(angle: angle, axis: -axis)
        let offset = rotation.act(baseVector)

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
