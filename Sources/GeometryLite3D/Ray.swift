import simd

public struct Ray: Equatable, Sendable {
    public var origin: SIMD3<Float>
    public private(set) var direction: SIMD3<Float>

    public init(origin: SIMD3<Float>, direction: SIMD3<Float>) {
        self.origin = origin
        self.direction = normalize(direction)
    }

    public func point(at distance: Float) -> SIMD3<Float> {
        origin + direction * distance
    }
}

public extension Ray {
    /// Ray through a point in clip-space x/y (-1...1, y up). `reversedDepth` selects which clip z is the near plane (Metal 0...1 depth).
    init(clipPoint: SIMD2<Float>, viewMatrix: float4x4, projectionMatrix: float4x4, reversedDepth: Bool = false) {
        let inverse = (projectionMatrix * viewMatrix).inverse
        let nearZ: Float = reversedDepth ? 1 : 0
        let near = inverse * SIMD4<Float>(clipPoint.x, clipPoint.y, nearZ, 1)
        let other = inverse * SIMD4<Float>(clipPoint.x, clipPoint.y, 0.5, 1)
        let nearPoint = near.xyz / near.w
        let otherPoint = other.xyz / other.w
        self.init(origin: nearPoint, direction: otherPoint - nearPoint)
    }

    /// Ray through a point in view coordinates (origin top-left, y down).
    init(viewPoint: SIMD2<Float>, viewSize: SIMD2<Float>, viewMatrix: float4x4, projectionMatrix: float4x4, reversedDepth: Bool = false) {
        let clipPoint = SIMD2<Float>(
            viewPoint.x / viewSize.x * 2 - 1,
            1 - viewPoint.y / viewSize.y * 2
        )
        self.init(clipPoint: clipPoint, viewMatrix: viewMatrix, projectionMatrix: projectionMatrix, reversedDepth: reversedDepth)
    }
}

public extension Ray {
    struct TriangleHit: Equatable, Sendable {
        public var distance: Float
        /// Weights for the triangle's vertices (a, b, c).
        public var barycentrics: SIMD3<Float>
    }

    struct BoxHit: Equatable, Sendable {
        public var distance: Float
        public var normal: SIMD3<Float>
    }

    /// Möller–Trumbore. Front faces wind counter-clockwise when seen from the ray.
    func intersect(triangle a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>, cullBackFaces: Bool = false) -> TriangleHit? {
        let epsilon: Float = 1e-7
        let edge1 = b - a
        let edge2 = c - a
        let p = cross(direction, edge2)
        let determinant = dot(edge1, p)
        if cullBackFaces {
            if determinant < epsilon {
                return nil
            }
        } else if abs(determinant) < epsilon {
            return nil
        }
        let inverseDeterminant = 1 / determinant
        let s = origin - a
        let u = dot(s, p) * inverseDeterminant
        if u < 0 || u > 1 {
            return nil
        }
        let q = cross(s, edge1)
        let v = dot(direction, q) * inverseDeterminant
        if v < 0 || u + v > 1 {
            return nil
        }
        let distance = dot(edge2, q) * inverseDeterminant
        if distance < 0 {
            return nil
        }
        return TriangleHit(distance: distance, barycentrics: [1 - u - v, u, v])
    }

    /// Slab test. Returns nil when the box is behind the ray or the origin is inside the box.
    func intersect(box: BoundingBox) -> BoxHit? {
        let inverseDirection = 1 / direction
        let t1 = (box.min - origin) * inverseDirection
        let t2 = (box.max - origin) * inverseDirection
        let tNear = simd.min(t1, t2)
        let tFar = simd.max(t1, t2)
        let entry = tNear.max()
        let exit = tFar.min()
        guard entry <= exit, entry >= 0 else {
            return nil
        }
        var normal = SIMD3<Float>.zero
        let axis = entry == tNear.x ? 0 : (entry == tNear.y ? 1 : 2)
        normal[axis] = direction[axis] > 0 ? -1 : 1
        return BoxHit(distance: entry, normal: normal)
    }
}
