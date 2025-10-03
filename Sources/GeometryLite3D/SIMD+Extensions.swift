import simd

public extension float4x4 {
    static let identity = float4x4(diagonal: [1, 1, 1, 1])

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

    init(translation: SIMD3<Float>) {
        self.init(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(translation.x, translation.y, translation.z, 1)
        )
    }

    init(scale: SIMD3<Float>) {
        self.init(
            SIMD4<Float>(scale.x, 0, 0, 0),
            SIMD4<Float>(0, scale.y, 0, 0),
            SIMD4<Float>(0, 0, scale.z, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }

    var canInvert: Bool {
        determinant != 0
    }

    var translation: SIMD3<Float> {
        get {
            self[3].xyz
        }
        set {
            self[3].xyz = newValue
        }
    }

    var upperLeft3x3: float3x3 {
        float3x3(columns: (
            SIMD3(columns.0.xyz),
            SIMD3(columns.1.xyz),
            SIMD3(columns.2.xyz)
        ))
    }
}

// MARK: -

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

// MARK: -

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

// MARK: -

public extension simd_quatf {
    static let identity = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
}

// MARK: -

public extension float4x4 {
    var scalars: [Float] {
        withUnsafeBytes(of: self) { buffer in
            Array(buffer.bindMemory(to: Float.self))
        }
    }
}

public extension float4x4 {
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
