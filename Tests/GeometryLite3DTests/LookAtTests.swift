@testable import GeometryLite3D
import simd
import Testing

struct LookAtTests {
    @Test
    func cameraMatrixBuildsOrthogonalBasis() {
        let lookAt = LookAt(position: [1, 2, 3], target: [4, 6, 5], up: [0, 1, 0])
        let matrix = lookAt.cameraMatrix

        let forward = normalize(lookAt.target - lookAt.position)
        let right = normalize(cross(forward, lookAt.up))
        let up = normalize(cross(right, forward))

        let column0 = matrix.columns.0.xyz
        let column1 = matrix.columns.1.xyz
        let column2 = matrix.columns.2.xyz
        let translation = matrix.columns.3.xyz

        #expect(column0.isApproximatelyEqual(to: right, absoluteTolerance: 1e-6))
        #expect(column1.isApproximatelyEqual(to: up, absoluteTolerance: 1e-6))
        #expect(column2.isApproximatelyEqual(to: -forward, absoluteTolerance: 1e-6))
        #expect(translation.isApproximatelyEqual(to: lookAt.position, absoluteTolerance: 1e-6))
    }

    @Test(arguments: [SIMD3<Float>(0, 10, 0), SIMD3<Float>(0, -10, 0)])
    func cameraMatrixHandlesUpParallelToForward(target: SIMD3<Float>) {
        let matrix = LookAt(position: .zero, target: target, up: [0, 1, 0]).cameraMatrix
        #expect(matrix.scalars.allSatisfy { $0.isFinite })
        #expect(abs(matrix.determinant - 1) < 1e-5)
        #expect(matrix.columns.2.xyz.isApproximatelyEqual(to: -normalize(target), absoluteTolerance: 1e-6))
    }

    @Test
    func viewMatrixIsInverseOfCameraMatrix() {
        let lookAt = LookAt(position: [-3, 1, 2], target: [0, 4, -1], up: [0, 0, 1])
        let camera = lookAt.cameraMatrix
        let view = lookAt.viewMatrix

        #expect(view.isApproximatelyEqual(to: camera.inverse, absoluteTolerance: 1e-6))

        let identity = camera * view
        #expect(identity.isApproximatelyEqual(to: float4x4.identity, absoluteTolerance: 1e-5))
    }
}
