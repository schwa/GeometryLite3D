import GeometryLite3D
import simd
import Spatial
import Testing

struct LookRotationTests {
    @Test(arguments: [
        (SIMD3<Float>(0, 0, 10), SIMD3<Float>(0, 0, 0), SIMD3<Float>(0, 0, -1)),
        (SIMD3<Float>(3, 4, 5), SIMD3<Float>(-1, 0, 2), SIMD3<Float>(0, 0, -1)),
        (SIMD3<Float>(1, 2, 3), SIMD3<Float>(4, -2, 0), SIMD3<Float>(0, 0, 1)),
        (SIMD3<Float>(0, 0, 0), SIMD3<Float>(5, 1, 0), SIMD3<Float>(1, 0, 0))
    ])
    func matchesSpatial(position: SIMD3<Float>, target: SIMD3<Float>, localFront: SIMD3<Float>) {
        // Spatial's forward is local +Z, so undo the rotation that takes +Z to localFront.
        let up = Vector3D(x: 0, y: 1, z: 0)
        let towardsTarget = simd_quatf(Rotation3D(forward: Vector3D(vector: SIMD3<Double>(target - position)), up: up))
        let towardsLocalFront = simd_quatf(Rotation3D(forward: Vector3D(vector: SIMD3<Double>(localFront)), up: up))
        let expected = towardsTarget * towardsLocalFront.inverse
        let rotation = simd_quatf.lookRotation(from: position, to: target, localFront: localFront)
        #expect(float4x4(rotation).isApproximatelyEqual(to: float4x4(expected), absoluteTolerance: 1e-5))
    }

    @Test
    func turnsFrontTowardsTarget() {
        let rotation = simd_quatf.lookRotation(from: [1, 1, 1], to: [4, 5, 1])
        #expect(rotation.act([0, 0, -1]).isApproximatelyEqual(to: [0.6, 0.8, 0], absoluteTolerance: 1e-5))
    }

    @Test
    func targetAtPositionGivesIdentity() {
        #expect(simd_quatf.lookRotation(from: [1, 2, 3], to: [1, 2, 3]) == .identity)
    }

    @Test
    func lookingAlongUpDoesNotProduceNaN() {
        let rotation = simd_quatf.lookRotation(from: .zero, to: [0, 10, 0])
        #expect(!rotation.vector.min().isNaN)
        #expect(rotation.act([0, 0, -1]).isApproximatelyEqual(to: [0, 1, 0], absoluteTolerance: 1e-5))
    }
}
