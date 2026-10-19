import simd

/// Right-handed frame with `forward` exactly along the input direction. If `up` is parallel to `forward`, a fallback up vector is used.
@usableFromInline
internal struct OrthonormalBasis {
    @usableFromInline internal var right: SIMD3<Float>
    @usableFromInline internal var up: SIMD3<Float>
    @usableFromInline internal var forward: SIMD3<Float>

    @inlinable
    internal init(forward: SIMD3<Float>, up: SIMD3<Float>) {
        self.forward = normalize(forward)
        self.right = perpendicular(to: self.forward, preferring: up)
        self.up = cross(right, self.forward)
    }

    /// Columns are right, up, forward.
    @inlinable
    internal var matrix: float3x3 {
        float3x3(columns: (right, up, forward))
    }
}

/// Unit vector perpendicular to `direction`, equal to normalize(cross(direction, preferredUp)) unless they are parallel.
@inlinable
internal func perpendicular(to direction: SIMD3<Float>, preferring preferredUp: SIMD3<Float> = [0, 1, 0]) -> SIMD3<Float> {
    let direction = normalize(direction)
    var right = cross(direction, normalize(preferredUp))
    if length(right) < 1e-6 {
        let fallbackUp: SIMD3<Float> = abs(direction.z) < 0.9 ? [0, 0, 1] : [1, 0, 0]
        right = cross(direction, fallbackUp)
    }
    return normalize(right)
}
