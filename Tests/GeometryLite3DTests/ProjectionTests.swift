import CoreGraphics
import GeometryLite3D
import simd
import Spatial
import Testing

private func spatialPerspective(fovY: Double, aspectRatio: Double, nearZ: Double, farZ: Double, reverseZ: Bool) -> float4x4 {
    let matrix = ProjectiveTransform3D(fovY: .degrees(fovY), aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ, reverseZ: reverseZ).matrix
    return float4x4(SIMD4<Float>(matrix.columns.0), SIMD4<Float>(matrix.columns.1), SIMD4<Float>(matrix.columns.2), SIMD4<Float>(matrix.columns.3))
}

struct ProjectionTests {
    @Test
    func standardPerspectiveMatchesSpatial() {
        let spatial = spatialPerspective(fovY: 60, aspectRatio: 2, nearZ: 1, farZ: 100, reverseZ: false)
        let projection = PerspectiveProjection(verticalAngleOfView: .degrees(60), depthMode: .standard(zClip: 1...100)).projectionMatrix(width: 2, height: 1)
        #expect(projection.isApproximatelyEqual(to: spatial, absoluteTolerance: 1e-6))
    }

    @Test
    func reversedFinitePerspectiveMatchesSpatial() {
        let spatial = spatialPerspective(fovY: 45, aspectRatio: 1.5, nearZ: 0.5, farZ: 50, reverseZ: true)
        let projection = PerspectiveProjection(verticalAngleOfView: .degrees(45), depthMode: .reversed(zClip: 0.5...50)).projectionMatrix(aspectRatio: 1.5)
        #expect(projection.isApproximatelyEqual(to: spatial, absoluteTolerance: 1e-6))
    }

    @Test
    func reversedInfinitePerspectiveMatchesSpatial() {
        let spatial = spatialPerspective(fovY: 70, aspectRatio: 0.75, nearZ: 0.1, farZ: .infinity, reverseZ: true)
        let projection = PerspectiveProjection(verticalAngleOfView: .degrees(70), depthMode: .reversedInfinite(zNear: 0.1)).projectionMatrix(aspectRatio: 0.75)
        #expect(projection.isApproximatelyEqual(to: spatial, absoluteTolerance: 1e-6))
    }

    @Test(arguments: [
        (SIMD3<Float>(0, 0, 10), SIMD3<Float>(0, 0, 0)),
        (SIMD3<Float>(3, 4, 5), SIMD3<Float>(-1, 0, 2))
    ])
    func lookAtMatchesSpatial(position: SIMD3<Float>, target: SIMD3<Float>) {
        let rotation = simd_quatf(Rotation3D(forward: Vector3D(vector: SIMD3<Double>(position - target)), up: Vector3D(x: 0, y: 1, z: 0)))
        let expected = float4x4(translation: position) * float4x4(rotation)
        let cameraMatrix = LookAt(position: position, target: target, up: [0, 1, 0]).cameraMatrix
        #expect(cameraMatrix.isApproximatelyEqual(to: expected, absoluteTolerance: 1e-5))
    }

    @Test
    func perspectiveProjectionConvenienceOverloadsMatch() {
        let projection = PerspectiveProjection(verticalAngleOfView: .degrees(45), depthMode: .standard(zClip: 0.5...150))
        let aspect: Float = 16 / 9

        let matrixDirect = projection.projectionMatrix(aspectRatio: aspect)
        let matrixVector = projection.projectionMatrix(for: SIMD2<Float>(16, 9))
        let matrixCGSize = projection.projectionMatrix(for: CGSize(width: 16, height: 9))
        let matrixWidthHeight = projection.projectionMatrix(width: 16, height: 9)

        #expect(matrixVector.isApproximatelyEqual(to: matrixDirect, absoluteTolerance: 1e-6))
        #expect(matrixCGSize.isApproximatelyEqual(to: matrixDirect, absoluteTolerance: 1e-6))
        #expect(matrixWidthHeight.isApproximatelyEqual(to: matrixDirect, absoluteTolerance: 1e-6))
    }

    @Test
    func standardPerspectiveMatchesManualComputation() {
        let near: Float = 1
        let far: Float = 10
        let aspect: Float = 4 / 3
        let projection = PerspectiveProjection(verticalAngleOfView: .degrees(90), depthMode: .standard(zClip: near...far))

        let matrix = projection.projectionMatrix(aspectRatio: aspect)

        let f: Float = 1 / tan(Float.pi / 4)
        let rangeInv: Float = 1 / (near - far)
        let expected = float4x4(
            SIMD4<Float>(f / aspect, 0, 0, 0),
            SIMD4<Float>(0, f, 0, 0),
            SIMD4<Float>(0, 0, far * rangeInv, -1),
            SIMD4<Float>(0, 0, far * near * rangeInv, 0)
        )

        #expect(matrix.isApproximatelyEqual(to: expected, absoluteTolerance: 1e-6))
    }

    @Test
    func reverseZPerspectiveMatchesClosedForm() {
        let projection = PerspectiveProjection(verticalAngleOfView: .degrees(60), depthMode: .reversedInfinite(zNear: 0.5))
        let aspect: Float = 21 / 9

        let matrix = projection.projectionMatrix(aspectRatio: aspect)

        let f: Float = 1 / tan(projection.verticalAngleOfView.radians * 0.5)
        let near: Float = 0.5
        let expected = float4x4(
            SIMD4<Float>(f / aspect, 0, 0, 0),
            SIMD4<Float>(0, f, 0, 0),
            SIMD4<Float>(0, 0, 0, -1),
            SIMD4<Float>(0, 0, near, 0)
        )

        #expect(matrix.isApproximatelyEqual(to: expected, absoluteTolerance: 1e-6))
    }

    @Test
    @available(*, deprecated)
    func legacyFloat4x4PerspectiveFormulaMatchesManual() {
        let aspect: Float = 2
        let fovy: Float = Float.pi / 3
        let near: Float = 0.25
        let far: Float = 400

        let matrix = float4x4.perspective(aspectRatio: aspect, fovy: fovy, near: near, far: far)

        let yScale = 1 / tan(fovy * 0.5)
        let xScale = yScale / aspect
        let zRange = far - near
        let zScale = -(far + near) / zRange
        let wzScale = -2 * far * near / zRange

        let expected = float4x4([
            SIMD4<Float>(xScale, 0, 0, 0),
            SIMD4<Float>(0, yScale, 0, 0),
            SIMD4<Float>(0, 0, zScale, -1),
            SIMD4<Float>(0, 0, wzScale, 0)
        ])

        #expect(matrix.isApproximatelyEqual(to: expected, absoluteTolerance: 1e-6))
    }
}
