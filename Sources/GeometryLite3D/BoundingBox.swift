import simd
import ModelIO

/// Bounding box information for 3D objects
public struct BoundingBox: Equatable, Sendable {
    public var min: SIMD3<Float>
    public var max: SIMD3<Float>

    public init(min: SIMD3<Float>, max: SIMD3<Float>) {
        self.min = min
        self.max = max
    }

    public func transformed(by transform: matrix_float4x4) -> Self {
        // Transform all 8 corners of the bounding box
        let corners = [
            SIMD3<Float>(min.x, min.y, min.z),
            SIMD3<Float>(max.x, min.y, min.z),
            SIMD3<Float>(min.x, max.y, min.z),
            SIMD3<Float>(max.x, max.y, min.z),
            SIMD3<Float>(min.x, min.y, max.z),
            SIMD3<Float>(max.x, min.y, max.z),
            SIMD3<Float>(min.x, max.y, max.z),
            SIMD3<Float>(max.x, max.y, max.z)
        ]

        var newMin = SIMD3<Float>(Float.infinity, Float.infinity, Float.infinity)
        var newMax = SIMD3<Float>(-Float.infinity, -Float.infinity, -Float.infinity)

        for corner in corners {
            let transformed = transform * SIMD4<Float>(corner, 1.0)
            let point = SIMD3<Float>(transformed.x, transformed.y, transformed.z)
            newMin = simd.min(newMin, point)
            newMax = simd.max(newMax, point)
        }

        return Self(min: newMin, max: newMax)
    }
}

public extension BoundingBox {
    init(from mdlBounds: MDLAxisAlignedBoundingBox) {
        self.min = mdlBounds.minBounds
        self.max = mdlBounds.maxBounds
    }
}
