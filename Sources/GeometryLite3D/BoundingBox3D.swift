import ModelIO
import simd

public struct BoundingBox3D: Equatable, Sendable, Codable {
    public var min: SIMD3<Float>
    public var max: SIMD3<Float>

    public init(min: SIMD3<Float>, max: SIMD3<Float>) {
        self.min = min
        self.max = max
    }

    public func transformed(by transform: float4x4) -> Self {
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

public extension BoundingBox3D {
    /// Returns nil for an empty sequence.
    init?<S: Sequence>(points: S) where S.Element == SIMD3<Float> {
        var iterator = points.makeIterator()
        guard let first = iterator.next() else {
            return nil
        }
        var minimum = first
        var maximum = first
        while let point = iterator.next() {
            minimum = simd.min(minimum, point)
            maximum = simd.max(maximum, point)
        }
        self.init(min: minimum, max: maximum)
    }

    var center: SIMD3<Float> {
        (min + max) * 0.5
    }

    var size: SIMD3<Float> {
        max - min
    }

    func union(_ other: Self) -> Self {
        Self(min: simd.min(min, other.min), max: simd.max(max, other.max))
    }

    func contains(_ point: SIMD3<Float>) -> Bool {
        all(point .>= min) && all(point .<= max)
    }
}

public extension BoundingBox3D {
    init(from mdlBounds: MDLAxisAlignedBoundingBox) {
        self.min = mdlBounds.minBounds
        self.max = mdlBounds.maxBounds
    }
}
