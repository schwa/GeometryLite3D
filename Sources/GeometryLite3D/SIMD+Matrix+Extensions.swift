import simd

public extension double4x4 {
    static let identity = double4x4(diagonal: [1, 1, 1, 1])

    @inlinable
    init(translation: SIMD3<Double>) {
        self.init(
            SIMD4<Double>(1, 0, 0, 0),
            SIMD4<Double>(0, 1, 0, 0),
            SIMD4<Double>(0, 0, 1, 0),
            SIMD4<Double>(translation.x, translation.y, translation.z, 1)
        )
    }

    @inlinable
    init(scale: SIMD3<Double>) {
        self.init(diagonal: SIMD4<Double>(scale, 1))
    }

    @inlinable
    var canInvert: Bool {
        determinant != 0
    }

    @inlinable
    var translation: SIMD3<Double> {
        get {
            self[3].xyz
        }
        set {
            self[3].xyz = newValue
        }
    }

    @inlinable
    var upperLeft3x3: double3x3 {
        double3x3(columns: (columns.0.xyz, columns.1.xyz, columns.2.xyz))
    }

    /// True when the transform flips triangle winding.
    @inlinable
    var isMirroring: Bool {
        determinant < 0
    }

    @inlinable
    var normalMatrix: double3x3 {
        upperLeft3x3.inverse.transpose
    }
}

public extension float4x4 {
    static let identity = float4x4(diagonal: [1, 1, 1, 1])

    @inlinable
    init(xRotation: AngleF) {
        let radians = Float(xRotation.radians)
        let c = cos(radians)
        let s = sin(radians)
        self.init([
            [1, 0, 0, 0],
            [0, c, -s, 0],
            [0, s, c, 0],
            [0, 0, 0, 1]
        ])
    }

    @inlinable
    init(yRotation: AngleF) {
        let radians = Float(yRotation.radians)
        let c = cos(radians)
        let s = sin(radians)
        self.init([
            [c, 0, s, 0],
            [0, 1, 0, 0],
            [-s, 0, c, 0],
            [0, 0, 0, 1]
        ])
    }

    @inlinable
    init(zRotation: AngleF) {
        let radians = Float(zRotation.radians)
        let c = cos(radians)
        let s = sin(radians)
        self.init([
            [c, -s, 0, 0],
            [s, c, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
    }

    @inlinable
    init(translation: SIMD3<Float>) {
        self.init(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(translation.x, translation.y, translation.z, 1)
        )
    }

    @inlinable
    init(scale: SIMD3<Float>) {
        self.init(
            SIMD4<Float>(scale.x, 0, 0, 0),
            SIMD4<Float>(0, scale.y, 0, 0),
            SIMD4<Float>(0, 0, scale.z, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }

    @inlinable
    var canInvert: Bool {
        determinant != 0
    }

    @inlinable
    var translation: SIMD3<Float> {
        get {
            self[3].xyz
        }
        set {
            self[3].xyz = newValue
        }
    }

    @inlinable
    var upperLeft3x3: float3x3 {
        float3x3(columns: (
            SIMD3(columns.0.xyz),
            SIMD3(columns.1.xyz),
            SIMD3(columns.2.xyz)
        ))
    }

    /// True when the transform flips triangle winding.
    @inlinable
    var isMirroring: Bool {
        determinant < 0
    }

    @inlinable
    var normalMatrix: float3x3 {
        upperLeft3x3.inverse.transpose
    }

    @inlinable
    var scalars: [Float] {
        withUnsafeBytes(of: self) { buffer in
            Array(buffer.bindMemory(to: Float.self))
        }
    }

    var formattedDescription: String {
        (0..<4).map { row in
            (0..<4).map { column in
                let value = self[column, row]
                return value.formatted(.number.precision(.fractionLength(4)))
            }
            .joined(separator: ", ")
        }
        .joined(separator: "\n")
    }
}
