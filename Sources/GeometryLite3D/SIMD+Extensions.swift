import simd

public extension SIMD3<Float> {
    static let unit = SIMD3<Float>(1, 1, 1)

    var normalized: SIMD3<Float> {
        normalize(self)
    }
}

public extension SIMD3 {
    var xy: SIMD2<Scalar> {
        get {
            .init(x, y)
        }
        set {
            x = newValue.x
            y = newValue.y
        }
    }

    func map<T>(_ transform: (Scalar) -> T) -> SIMD3<T> where T: SIMDScalar {
        .init(transform(x), transform(y), transform(z))
    }
}

public extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        get {
            [x, y, z]
        }
        set {
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }

    func map<T>(_ transform: (Scalar) -> T) -> SIMD4<T> where T: SIMDScalar {
        .init(transform(x), transform(y), transform(z), transform(w))
    }

    var scalars: [Scalar] {
        [x, y, z, w]
    }
}

public extension simd_quatf {
    static let identity = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)

    /// Rotation that turns `localFront` to `target` and keeps `worldUp` up.
    static func lookRotation(from position: SIMD3<Float>, to target: SIMD3<Float>, up worldUp: SIMD3<Float> = [0, 1, 0], localFront: SIMD3<Float> = [0, 0, -1]) -> simd_quatf {
        let offset = target - position
        guard simd.length(offset) > 1e-6 else {
            return .identity
        }
        let worldBasis = orthonormalBasis(forward: normalize(offset), up: worldUp)
        let localBasis = orthonormalBasis(forward: normalize(localFront), up: [0, 1, 0])
        return simd_quatf(worldBasis * localBasis.transpose).normalized
    }

    private static func orthonormalBasis(forward: SIMD3<Float>, up: SIMD3<Float>) -> float3x3 {
        var right = cross(forward, up)
        if simd.length(right) < 1e-6 {
            let fallbackUp: SIMD3<Float> = abs(forward.z) < 0.9 ? [0, 0, 1] : [1, 0, 0]
            right = cross(forward, fallbackUp)
        }
        right = normalize(right)
        let trueUp = cross(right, forward)
        return float3x3(columns: (right, trueUp, forward))
    }
}

internal extension SIMD3<Float> {
    mutating func scale(to desiredLength: Float) {
        let currentLength = length(self)
        if currentLength != 0 {
            self *= desiredLength / currentLength
        }
    }
}
