import simd

/// Six planes from a view-projection matrix. Each normal points into the frustum. Clip z must be in 0...w (standard or reverse Z).
public struct Frustum: Equatable, Sendable {
    public var left: SIMD4<Float>
    public var right: SIMD4<Float>
    public var bottom: SIMD4<Float>
    public var top: SIMD4<Float>
    public var near: SIMD4<Float>
    public var far: SIMD4<Float>

    @inlinable
    public init(viewProjection matrix: float4x4) {
        let transposed = matrix.transpose
        let row0 = transposed.columns.0
        let row1 = transposed.columns.1
        let row2 = transposed.columns.2
        let row3 = transposed.columns.3
        left = row3 + row0
        right = row3 - row0
        bottom = row3 + row1
        top = row3 - row1
        near = row2
        far = row3 - row2
    }

    @inlinable
    public var planes: [SIMD4<Float>] {
        [left, right, bottom, top, near, far]
    }

    /// Can return true for a box that is near a corner but outside the frustum.
    @inlinable
    public func intersects(_ box: BoundingBox3D) -> Bool {
        isInside(box, plane: left)
            && isInside(box, plane: right)
            && isInside(box, plane: bottom)
            && isInside(box, plane: top)
            && isInside(box, plane: near)
            && isInside(box, plane: far)
    }

    @inlinable
    internal func isInside(_ box: BoundingBox3D, plane: SIMD4<Float>) -> Bool {
        let normal = plane.xyz
        let positiveVertex = SIMD3<Float>(
            normal.x >= 0 ? box.max.x : box.min.x,
            normal.y >= 0 ? box.max.y : box.min.y,
            normal.z >= 0 ? box.max.z : box.min.z
        )
        return dot(normal, positiveVertex) + plane.w >= 0
    }
}
