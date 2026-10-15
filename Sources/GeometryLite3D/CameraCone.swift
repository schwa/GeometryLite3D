import simd

public struct CameraCone: Sendable, Equatable {
    public var parameters: CameraConeParameters
    public var rotation: AngleF
    public var height: Float

    public init(parameters: CameraConeParameters, rotation: AngleF, height: Float) {
        self.parameters = parameters
        self.rotation = rotation
        self.height = height
    }

    public var cameraTransform: float4x4 {
        parameters.cameraMatrix(angle: rotation.radians, t: height)
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

    /// The point the camera looks at.
    var target: SIMD3<Float> {
        centerA
    }

    func cameraMatrix(angle: Float, t: Float, up: SIMD3<Float> = [0, 1, 0]) -> float4x4 {
        LookAt(position: cameraPosition(angle: angle, t: t), target: target, up: up).cameraMatrix
    }
}
