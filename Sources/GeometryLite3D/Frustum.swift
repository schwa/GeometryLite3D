import simd

/// Six inward-facing planes (xyz normal, w distance) from a view-projection matrix in Metal clip space (0 <= z <= w).
public struct Frustum: Equatable, Sendable {
    public var planes: [SIMD4<Float>]

    public init(viewProjection matrix: float4x4) {
        let transposed = matrix.transpose
        let row0 = transposed.columns.0
        let row1 = transposed.columns.1
        let row2 = transposed.columns.2
        let row3 = transposed.columns.3
        planes = [
            row3 + row0,
            row3 - row0,
            row3 + row1,
            row3 - row1,
            row2,
            row3 - row2
        ]
    }

    /// Conservative: may return true for some boxes just outside the corners.
    public func intersects(_ box: BoundingBox3D) -> Bool {
        for plane in planes {
            let normal = plane.xyz
            let positiveVertex = SIMD3<Float>(
                normal.x >= 0 ? box.max.x : box.min.x,
                normal.y >= 0 ? box.max.y : box.min.y,
                normal.z >= 0 ? box.max.z : box.min.z
            )
            if dot(normal, positiveVertex) + plane.w < 0 {
                return false
            }
        }
        return true
    }
}
