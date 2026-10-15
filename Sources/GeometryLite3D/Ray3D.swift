import simd

public struct Ray3D: Equatable, Sendable {
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

public extension Ray3D {
    /// Ray through a clip-space point. x and y are in -1...1, with y up. Depth is 0...1. If `reversedDepth` is true, the near plane is at 1.
    init(clipPoint: SIMD2<Float>, viewMatrix: float4x4, projectionMatrix: float4x4, reversedDepth: Bool = false) {
        let inverse = (projectionMatrix * viewMatrix).inverse
        let nearZ: Float = reversedDepth ? 1 : 0
        let near = inverse * SIMD4<Float>(clipPoint.x, clipPoint.y, nearZ, 1)
        let other = inverse * SIMD4<Float>(clipPoint.x, clipPoint.y, 0.5, 1)
        let nearPoint = near.xyz / near.w
        let otherPoint = other.xyz / other.w
        self.init(origin: nearPoint, direction: otherPoint - nearPoint)
    }

    /// Ray through a point in view coordinates (origin top-left, y down). Prefer `ViewProjection.ray(through:)`, which gets the depth direction from the projection.
    init(viewPoint: SIMD2<Float>, viewSize: SIMD2<Float>, viewMatrix: float4x4, projectionMatrix: float4x4, reversedDepth: Bool = false) {
        self = ViewProjection(viewMatrix: viewMatrix, projectionMatrix: projectionMatrix, isReversedDepth: reversedDepth, viewSize: viewSize).ray(through: viewPoint)
    }
}

public extension Ray3D {
    struct TriangleHit: Equatable, Sendable {
        public var distance: Float
        /// Weights for the triangle's vertices (a, b, c).
        public var barycentrics: SIMD3<Float>
    }

    struct BoxHit: Equatable, Sendable {
        public var distance: Float
        public var normal: SIMD3<Float>
    }

    /// Uses the Möller–Trumbore algorithm. Front faces are counter-clockwise when seen from the ray origin.
    func intersect(triangle a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>, cullBackFaces: Bool = false) -> TriangleHit? {
        // The determinant scales with edge length squared, so keep this small enough for millimetre triangles.
        let epsilon: Float = 1e-12
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

    /// Uses the slab test. Returns nil if the box is behind the ray or if the ray origin is inside the box.
    func intersect(box: BoundingBox3D) -> BoxHit? {
        let inverseDirection = 1 / direction
        let t1 = (box.min - origin) * inverseDirection
        let t2 = (box.max - origin) * inverseDirection
        var tNear = simd.min(t1, t2)
        var tFar = simd.max(t1, t2)
        // A zero direction component gives 0 * inf = NaN on a face plane. Decide those slabs from the origin alone.
        let parallel = direction .== 0
        let insideSlab = (origin .>= box.min) .& (origin .<= box.max)
        let infinity = SIMD3<Float>(repeating: .infinity)
        tNear.replace(with: infinity.replacing(with: -infinity, where: insideSlab), where: parallel)
        tFar.replace(with: (-infinity).replacing(with: infinity, where: insideSlab), where: parallel)
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
