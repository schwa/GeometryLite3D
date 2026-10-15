import GeometryLite3D
import SceneKit
import simd
import Testing

struct LookRotationTests {
    @Test(arguments: [
        (SIMD3<Float>(0, 0, 10), SIMD3<Float>(0, 0, 0), SIMD3<Float>(0, 0, -1)),
        (SIMD3<Float>(3, 4, 5), SIMD3<Float>(-1, 0, 2), SIMD3<Float>(0, 0, -1)),
        (SIMD3<Float>(1, 2, 3), SIMD3<Float>(4, -2, 0), SIMD3<Float>(0, 0, 1)),
        (SIMD3<Float>(0, 0, 0), SIMD3<Float>(5, 1, 0), SIMD3<Float>(1, 0, 0))
    ])
    func matchesSceneKit(position: SIMD3<Float>, target: SIMD3<Float>, localFront: SIMD3<Float>) {
        let node = SCNNode()
        node.simdPosition = position
        node.simdLook(at: target, up: [0, 1, 0], localFront: localFront)
        let rotation = simd_quatf.lookRotation(from: position, to: target, localFront: localFront)
        #expect(float4x4(rotation).isApproximatelyEqual(to: float4x4(node.simdOrientation), absoluteTolerance: 1e-5))
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
