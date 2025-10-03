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
