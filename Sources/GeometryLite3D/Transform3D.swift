import simd

public struct Transform3D: Equatable, Sendable {
    public var translation: SIMD3<Float>
    public var rotation: simd_quatf
    public var scale: SIMD3<Float>

    public init(translation: SIMD3<Float> = .zero, rotation: simd_quatf = .identity, scale: SIMD3<Float> = .one) {
        self.translation = translation
        self.rotation = rotation
        self.scale = scale
    }

    public static let identity = Self()
}

extension Transform3D: Codable {
    private enum CodingKeys: String, CodingKey {
        case translation
        case rotation
        case scale
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        translation = try container.decode(SIMD3<Float>.self, forKey: .translation)
        rotation = simd_quatf(vector: try container.decode(SIMD4<Float>.self, forKey: .rotation))
        scale = try container.decode(SIMD3<Float>.self, forKey: .scale)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(translation, forKey: .translation)
        // simd_quatf is not Codable. Store the vector as [ix, iy, iz, r].
        try container.encode(rotation.vector, forKey: .rotation)
        try container.encode(scale, forKey: .scale)
    }
}

public extension Transform3D {
    /// Returns nil if the matrix does not decompose, or if it has skew or perspective (the result would not rebuild the matrix).
    init?(matrix: float4x4, tolerance: Float = 1e-4) {
        guard let components = matrix.decompose else {
            return nil
        }
        self.init(translation: components.translation, rotation: components.rotation, scale: components.scale)
        let magnitude = matrix.scalars.reduce(1) { max($0, abs($1)) }
        guard self.matrix.isApproximatelyEqual(to: matrix, absoluteTolerance: tolerance * magnitude) else {
            return nil
        }
    }

    var matrix: float4x4 {
        float4x4(translation: translation) * float4x4(rotation) * float4x4(scale: scale)
    }

    func interpolated(to other: Self, amount: Float) -> Self {
        Self(
            translation: mix(translation, other.translation, t: amount),
            rotation: simd_slerp(rotation, other.rotation, amount),
            scale: mix(scale, other.scale, t: amount)
        )
    }
}
