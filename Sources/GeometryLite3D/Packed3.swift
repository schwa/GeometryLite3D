import simd

/// Three packed scalars without the padding of SIMD3, for buffer layouts.
public struct Packed3<Scalar> where Scalar: SIMDScalar {
    public var x: Scalar
    public var y: Scalar
    public var z: Scalar

    public init(x: Scalar, y: Scalar, z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public extension Packed3 {
    init(_ other: SIMD3<Scalar>) {
        self.init(x: other.x, y: other.y, z: other.z)
    }
}

public extension Packed3 {
    subscript(i: Int) -> Scalar {
        get {
            precondition((0..<3).contains(i))
            switch i {
            case 0:
                return x

            case 1:
                return y

            default:
                return z
            }
        }
        set {
            precondition((0..<3).contains(i))
            switch i {
            case 0:
                x = newValue

            case 1:
                y = newValue

            default:
                z = newValue
            }
        }
    }
}

extension Packed3: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Scalar...) {
        x = elements[0]
        y = elements[1]
        z = elements[2]
    }
}

extension Packed3: Sendable where Scalar: Sendable {
}

extension Packed3: Equatable where Scalar: Equatable {
}

public extension Packed3 where Scalar: Numeric {
    static func * (lhs: Self, rhs: Scalar) -> Self {
        Self(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
}

#if os(iOS) || (os(macOS) && !arch(x86_64))
public extension Packed3 where Scalar == Float {
    init(_ other: Packed3<Float16>) {
        self.init(x: Float(other.x), y: Float(other.y), z: Float(other.z))
    }
}

public extension Packed3 where Scalar == Float16 {
    init(_ other: Packed3<Float>) {
        self.init(x: Float16(other.x), y: Float16(other.y), z: Float16(other.z))
    }
    init(_ other: SIMD3<Float>) {
        self.init(x: Float16(other.x), y: Float16(other.y), z: Float16(other.z))
    }
}
#endif // os(iOS) || (os(macOS) && !arch(x86_64))

public extension SIMD3<Float> {
    init(_ other: Packed3<Float>) {
        self.init(x: other.x, y: other.y, z: other.z)
    }
}
