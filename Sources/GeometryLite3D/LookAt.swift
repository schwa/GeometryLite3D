import simd

public struct LookAt: Equatable, Sendable {
    public var position: SIMD3<Float>
    public var target: SIMD3<Float>
    public var up: SIMD3<Float>

    public init(position: SIMD3<Float>, target: SIMD3<Float>, up: SIMD3<Float>) {
        self.position = position
        self.target = target
        self.up = up
    }
}

public extension LookAt {
    var cameraMatrix: float4x4 {
        let f = normalize(target - position)
        let r = normalize(cross(f, up))
        let u = normalize(cross(r, f))
        return float4x4(
            SIMD4<Float>(r, 0),
            SIMD4<Float>(u, 0),
            SIMD4<Float>(-f, 0),
            SIMD4<Float>(position, 1)
        )
    }

    var viewMatrix: float4x4 {
        cameraMatrix.inverse
    }
}

@available(*, deprecated, message: "Use LookAt struct instead")
public extension float4x4 {
    static func look(at target: SIMD3<Float>, from eye: SIMD3<Float>, up: SIMD3<Float>) -> simd_float4x4 {
        let forward: SIMD3<Float> = (target - eye).normalized

        // Side = forward x up
        let side = simd_cross(forward, up).normalized

        // Recompute up as: up = side x forward
        let up_ = simd_cross(side, forward).normalized

        var matrix2: simd_float4x4 = .identity

        matrix2[0] = SIMD4<Float>(side, 0)
        matrix2[1] = SIMD4<Float>(up_, 0)
        matrix2[2] = SIMD4<Float>(-forward, 0)
        matrix2[3] = [0, 0, 0, 1]

        return simd_float4x4(translation: eye) * matrix2
    }
}

