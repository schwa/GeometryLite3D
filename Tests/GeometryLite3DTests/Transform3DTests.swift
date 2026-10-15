import GeometryLite3D
import simd
import Testing

struct Transform3DTests {
    @Test
    func identityMatrix() {
        #expect(Transform3D.identity.matrix == .identity)
    }

    @Test
    func matrixAppliesScaleThenRotationThenTranslation() {
        let transform = Transform3D(translation: [10, 0, 0], rotation: simd_quatf(angle: .pi / 2, axis: [0, 0, 1]), scale: [2, 2, 2])
        let point = transform.matrix * SIMD4<Float>(1, 0, 0, 1)
        #expect(point.xyz.isApproximatelyEqual(to: [10, 2, 0], absoluteTolerance: 1e-5))
    }

    @Test
    func roundTripsThroughMatrix() {
        let transform = Transform3D(translation: [1, -2, 3], rotation: simd_quatf(angle: 0.7, axis: normalize(SIMD3<Float>(1, 1, 0))), scale: [1, 2, 3])
        let roundTripped = Transform3D(matrix: transform.matrix)
        #expect(roundTripped.matrix.isApproximatelyEqual(to: transform.matrix, absoluteTolerance: 1e-5))
    }

    @Test
    func nonDecomposableMatrixGivesIdentity() {
        #expect(Transform3D(matrix: float4x4()) == .identity)
    }

    @Test
    func interpolatesHalfway() {
        let start = Transform3D.identity
        let end = Transform3D(translation: [2, 4, 6], rotation: simd_quatf(angle: .pi / 2, axis: [0, 1, 0]), scale: [3, 3, 3])
        let middle = start.interpolated(to: end, amount: 0.5)
        #expect(middle.translation.isApproximatelyEqual(to: [1, 2, 3], absoluteTolerance: 1e-6))
        #expect(middle.scale.isApproximatelyEqual(to: [2, 2, 2], absoluteTolerance: 1e-6))
        #expect(middle.rotation.isApproximatelyEqual(to: simd_quatf(angle: .pi / 4, axis: [0, 1, 0]), absoluteTolerance: 1e-6))
    }
}
