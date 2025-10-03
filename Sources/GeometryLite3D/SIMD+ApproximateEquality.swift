import simd
import Numerics

public extension SIMD where Scalar: BinaryFloatingPoint {
    // Note: This is a per-scalar comparison and does not consider vector as a whole.
    func isApproximatelyEqual(to other: Self, absoluteTolerance: Scalar, releativeTolerance: Scalar = 0, norm: (Scalar) -> Scalar = \.magnitude) -> Bool {
        (0..<Self.scalarCount).allSatisfy { index in
            let a = self[index]
            let b = other[index]
            return a.isApproximatelyEqual(to: b, absoluteTolerance: absoluteTolerance, relativeTolerance: releativeTolerance, norm: norm)
        }
    }
}

public extension float4x4 {
    func isApproximatelyEqual(to other: Self, absoluteTolerance: Float, releativeTolerance: Float = 0, norm: (Float) -> Float = \.magnitude) -> Bool {
        zip(self.scalars, other.scalars).allSatisfy { a, b in
            a.isApproximatelyEqual(to: b, absoluteTolerance: absoluteTolerance, relativeTolerance: releativeTolerance, norm: norm)
        }
    }
}

public extension simd_quatf {
    func isApproximatelyEqual(to other: Self, absoluteTolerance: Float, releativeTolerance: Float = 0, norm: (Float) -> Float = \.magnitude) -> Bool {
        if vector.isApproximatelyEqual(to: other.vector, absoluteTolerance: absoluteTolerance, releativeTolerance: releativeTolerance, norm: norm) {
            return true
        }
        // Quaternions q and -q encode the same rotation; treat them as equivalent.
        return vector.isApproximatelyEqual(to: -other.vector, absoluteTolerance: absoluteTolerance, releativeTolerance: releativeTolerance, norm: norm)
    }
}
