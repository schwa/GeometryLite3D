import simd

public struct LookAt: Equatable, Sendable {
    public var position: SIMD3<Float>
    public var target: SIMD3<Float>
    public var up: SIMD3<Float>

    @inlinable
    public init(position: SIMD3<Float>, target: SIMD3<Float>, up: SIMD3<Float>) {
        self.position = position
        self.target = target
        self.up = up
    }
}

public extension LookAt {
    @inlinable
    var cameraMatrix: float4x4 {
        let basis = OrthonormalBasis(forward: target - position, up: up)
        return float4x4(
            SIMD4<Float>(basis.right, 0),
            SIMD4<Float>(basis.up, 0),
            SIMD4<Float>(-basis.forward, 0),
            SIMD4<Float>(position, 1)
        )
    }

    @inlinable
    var viewMatrix: float4x4 {
        cameraMatrix.inverse
    }
}
