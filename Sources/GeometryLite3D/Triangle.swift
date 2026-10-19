import simd

public struct TriangleClosestPoint: Equatable, Sendable {
    public var point: SIMD3<Float>
    /// Weights for the triangle's vertices (a, b, c).
    public var barycentrics: SIMD3<Float>
}

/// Closest point on triangle (a, b, c) to `p`. Uses the Voronoi-region method (Ericson, Real-Time Collision Detection, 5.1.5).
public func closestPoint(onTriangle a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>, to p: SIMD3<Float>) -> TriangleClosestPoint {
    let ab = b - a
    let ac = c - a
    let ap = p - a
    let d1 = dot(ab, ap)
    let d2 = dot(ac, ap)
    if d1 <= 0, d2 <= 0 {
        return TriangleClosestPoint(point: a, barycentrics: [1, 0, 0])
    }
    let bp = p - b
    let d3 = dot(ab, bp)
    let d4 = dot(ac, bp)
    if d3 >= 0, d4 <= d3 {
        return TriangleClosestPoint(point: b, barycentrics: [0, 1, 0])
    }
    let vc = d1 * d4 - d3 * d2
    if vc <= 0, d1 >= 0, d3 <= 0 {
        let v = d1 / (d1 - d3)
        return TriangleClosestPoint(point: a + v * ab, barycentrics: [1 - v, v, 0])
    }
    let cp = p - c
    let d5 = dot(ab, cp)
    let d6 = dot(ac, cp)
    if d6 >= 0, d5 <= d6 {
        return TriangleClosestPoint(point: c, barycentrics: [0, 0, 1])
    }
    let vb = d5 * d2 - d1 * d6
    if vb <= 0, d2 >= 0, d6 <= 0 {
        let w = d2 / (d2 - d6)
        return TriangleClosestPoint(point: a + w * ac, barycentrics: [1 - w, 0, w])
    }
    let va = d3 * d6 - d5 * d4
    if va <= 0, d4 - d3 >= 0, d5 - d6 >= 0 {
        let w = (d4 - d3) / ((d4 - d3) + (d5 - d6))
        return TriangleClosestPoint(point: b + w * (c - b), barycentrics: [0, 1 - w, w])
    }
    // Equals the squared length of cross(ab, ac), and is positive here because degenerate triangles exit through a vertex or edge case above.
    let denominator = va + vb + vc
    let v = vb / denominator
    let w = vc / denominator
    return TriangleClosestPoint(point: a + ab * v + ac * w, barycentrics: [1 - v - w, v, w])
}

/// Signed solid angle of triangle (a, b, c) seen from `p` (Van Oosterom and Strackee). Positive when `p` is behind the triangle (its counter-clockwise normal points away from `p`), so an outward-wound closed mesh sums to 4π from inside and 0 from outside.
public func solidAngle(ofTriangle a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>, from p: SIMD3<Float>) -> Float {
    let ra = a - p
    let rb = b - p
    let rc = c - p
    let la = length(ra)
    let lb = length(rb)
    let lc = length(rc)
    let numerator = dot(ra, cross(rb, rc))
    let denominator = la * lb * lc + dot(ra, rb) * lc + dot(ra, rc) * lb + dot(rb, rc) * la
    return 2 * atan2(numerator, denominator)
}
