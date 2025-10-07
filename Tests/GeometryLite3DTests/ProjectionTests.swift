import GeometryLite3D
import SceneKit
import simd
import Testing

struct ProjectionTests {
    @Test
    func testSceneKitGroundTruth() {
        let scene = SCNScene()
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zNear = 1
        camera.zFar = 100
        camera.fieldOfView = 60
        camera.projectionDirection = .vertical
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
        let sceneKitProjection = float4x4(camera.projectionTransform(withViewportSize: CGSize(width: 2, height: 1)))
        let newProjection = PerspectiveProjection(verticalAngleOfView: .degrees(Float(camera.fieldOfView)), depthMode: .standard(zClip: 1...100)).projectionMatrix(width: 2, height: 1)
        #expect(newProjection.isApproximatelyEqual(to: sceneKitProjection, absoluteTolerance: 1e-6))

        cameraNode.simdPosition = [0, 0, 10]
        cameraNode.simdLook(at: [0, 0, 0], up: [0, 1, 0], localFront: [0, 0, -1])
        let sceneKitCameraMatrix = cameraNode.simdTransform
        let newLookAtCameraMatrix = LookAt(position: [0, 0, 10], target: [0, 0, 0], up: [0, 1, 0]).cameraMatrix

        #expect(newLookAtCameraMatrix == sceneKitCameraMatrix)
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
            SIMD4<Float>(0, 0, (far + near) * rangeInv, -1),
            SIMD4<Float>(0, 0, 2 * far * near * rangeInv, 0)
        )

        #expect(matrix.isApproximatelyEqual(to: expected, absoluteTolerance: 1e-6))
    }

    @Test
    func reverseZPerspectiveMatchesClosedForm() {
        let projection = PerspectiveProjection(verticalAngleOfView: .degrees(60), depthMode: .reversed(zMin: 0.5))
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
