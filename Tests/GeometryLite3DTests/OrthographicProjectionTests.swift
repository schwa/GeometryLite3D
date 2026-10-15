import GeometryLite3D
import SceneKit
import simd
import Testing

struct OrthographicProjectionTests {
    @Test
    func standardMatchesSceneKit() {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 5
        camera.zNear = 1
        camera.zFar = 100
        camera.projectionDirection = .vertical
        let sceneKitProjection = float4x4(camera.projectionTransform(withViewportSize: CGSize(width: 2, height: 1)))
        let projection = OrthographicProjection(halfHeight: 5, depthMode: .standard(zClip: 1...100)).projectionMatrix(width: 2, height: 1)
        #expect(projection.isApproximatelyEqual(to: sceneKitProjection, absoluteTolerance: 1e-6))
    }

    @Test
    func reversedMapsNearToOneAndFarToZero() {
        let matrix = OrthographicProjection(halfHeight: 2, depthMode: .reversed(zClip: 0.5...50)).projectionMatrix(aspectRatio: 2)
        let near = matrix * SIMD4<Float>(4, 2, -0.5, 1)
        let far = matrix * SIMD4<Float>(-4, -2, -50, 1)
        #expect(near.isApproximatelyEqual(to: [1, 1, 1, 1], absoluteTolerance: 1e-6))
        #expect(far.isApproximatelyEqual(to: [-1, -1, 0, 1], absoluteTolerance: 1e-6))
    }
}
