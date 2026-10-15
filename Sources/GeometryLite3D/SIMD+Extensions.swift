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
        let worldBasis = OrthonormalBasis(forward: offset, up: worldUp).matrix
        let localBasis = OrthonormalBasis(forward: localFront, up: [0, 1, 0]).matrix
        return simd_quatf(worldBasis * localBasis.transpose).normalized
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
