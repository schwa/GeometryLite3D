import Testing
import simd
@testable import GeometryLite3D

struct SIMDApproximateEqualityTests {
    @Test
    func simdVectorApproximateEqualityHandlesArbitraryLength() {
        let base = SIMD3<Float>(1, 2, 3)
        let perturbation: Float = 1e-6
        let perturbed = base + SIMD3<Float>(repeating: perturbation)
        #expect(base.isApproximatelyEqual(to: perturbed, absoluteTolerance: 1e-5))
    }

    @Test
    func quaternionApproximateEqualityAcceptsSmallRotationalDifferences() {
        let delta: Float = 1e-6
        let q1 = simd_quatf(angle: Float.pi / 4, axis: [0, 1, 0])
        let q2 = simd_quatf(angle: Float.pi / 4 + delta, axis: [0, 1, 0])
        #expect(q1.isApproximatelyEqual(to: q2, absoluteTolerance: 1e-5))
    }

    @Test
    func quaternionApproximateEqualityTreatsNegatedAsEquivalent() {
        let q = simd_quatf(angle: Float.pi / 3, axis: [1, 0, 0])
        let negated = simd_quatf(ix: -q.imag.x, iy: -q.imag.y, iz: -q.imag.z, r: -q.real)
        #expect(q.isApproximatelyEqual(to: negated, absoluteTolerance: 1e-6))
    }
}
