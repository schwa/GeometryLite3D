import GeometryLite3D
import simd
import Testing

struct ProjectionHelpersTests {
    private func depth(_ clip: SIMD4<Float>) -> Float {
        clip.z / clip.w
    }

    @Test
    func reversedFinitePerspectiveMapsNearToOneAndFarToZero() {
        let matrix = PerspectiveProjection(verticalAngleOfView: .degrees(60), depthMode: .reversedFinite(zClip: 0.5...50)).projectionMatrix(aspectRatio: 1.5)
        #expect(abs(depth(matrix * SIMD4<Float>(0, 0, -0.5, 1)) - 1) < 1e-6)
        #expect(abs(depth(matrix * SIMD4<Float>(0, 0, -50, 1))) < 1e-6)
    }

    @Test
    func reversedDepthRemapsZToWMinusZ() {
        let clip = float4x4.reversedDepth * SIMD4<Float>(1, 2, 0.25, 2)
        #expect(clip == [1, 2, 1.75, 2])
    }

    @Test
    func reversedDepthMatchesReversedOrthographic() {
        let near: Float = 1
        let far: Float = 20
        let standardMetal = float4x4(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, -1 / (far - near), 0),
            SIMD4<Float>(0, 0, -near / (far - near), 1)
        )
        let reversed = OrthographicProjection(halfHeight: 1, depthMode: .reversed(zClip: near...far)).projectionMatrix(aspectRatio: 1)
        #expect((float4x4.reversedDepth * standardMetal).isApproximatelyEqual(to: reversed, absoluteTolerance: 1e-6))
    }

    @Test
    func viewMatrixMatchesLookAt() {
        let eye: SIMD3<Float> = [1, 2, 3]
        let forward: SIMD3<Float> = [0, 0, -1]
        let expected = LookAt(position: eye, target: eye + forward, up: [0, 1, 0]).viewMatrix
        #expect(float4x4.viewMatrix(eye: eye, forward: forward).isApproximatelyEqual(to: expected, absoluteTolerance: 1e-6))
    }

    @Test
    func viewMatrixHandlesForwardParallelToUp() {
        let matrix = float4x4.viewMatrix(eye: [0, 5, 0], forward: [0, -1, 0])
        #expect(!matrix.scalars.contains { $0.isNaN })
        let eyeInView = matrix * SIMD4<Float>(0, 5, 0, 1)
        #expect(eyeInView.isApproximatelyEqual(to: [0, 0, 0, 1], absoluteTolerance: 1e-6))
        let below = matrix * SIMD4<Float>(0, 0, 0, 1)
        #expect(below.isApproximatelyEqual(to: [0, 0, -5, 1], absoluteTolerance: 1e-5))
    }
}
