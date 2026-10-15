import Foundation
import GeometryLite3D
import simd
import Testing

struct Transform3DTests {
    @Test
    func codableRoundTrip() throws {
        let transform = Transform3D(translation: [1, 2, 3], rotation: simd_quatf(angle: 0.5, axis: [0, 1, 0]), scale: [2, 3, 4])
        let data = try JSONEncoder().encode(transform)
        #expect(try JSONDecoder().decode(Transform3D.self, from: data) == transform)
    }

    @Test
    func boundingBoxCodableRoundTrip() throws {
        let box = BoundingBox3D(min: [-1, -2, -3], max: [4, 5, 6])
        let data = try JSONEncoder().encode(box)
        #expect(try JSONDecoder().decode(BoundingBox3D.self, from: data) == box)
    }

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
    func roundTripsThroughMatrix() throws {
        let transform = Transform3D(translation: [1, -2, 3], rotation: simd_quatf(angle: 0.7, axis: normalize(SIMD3<Float>(1, 1, 0))), scale: [1, 2, 3])
        let roundTripped = try #require(Transform3D(matrix: transform.matrix))
        #expect(roundTripped.matrix.isApproximatelyEqual(to: transform.matrix, absoluteTolerance: 1e-5))
    }

    @Test
    func roundTripsMirroringMatrix() throws {
        let matrix = float4x4(scale: [-2, 3, 4])
        let transform = try #require(Transform3D(matrix: matrix))
        #expect(transform.matrix.isApproximatelyEqual(to: matrix, absoluteTolerance: 1e-5))
    }

    @Test
    func nonDecomposableMatrixIsNil() {
        #expect(Transform3D(matrix: float4x4()) == nil)
    }

    @Test
    func skewMatrixIsNil() {
        let skew = float4x4([1, 0, 0, 0], [0.5, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1])
        #expect(Transform3D(matrix: skew) == nil)
    }

    @Test
    func perspectiveMatrixIsNil() {
        let projection = PerspectiveProjection().projectionMatrix(aspectRatio: 1)
        #expect(Transform3D(matrix: projection) == nil)
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
