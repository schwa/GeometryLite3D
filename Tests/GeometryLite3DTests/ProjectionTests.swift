import GeometryLite3D
import Testing
import simd
import SceneKit

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
        let newProjection = PerspectiveProjection(verticalAngleOfView: .degrees(Float(camera.fieldOfView)), zClip: 1...100).projectionMatrix(width: 2, height: 1)
        #expect(newProjection.isApproximatelyEqual(to: sceneKitProjection, absoluteTolerance: 1e-6))

        cameraNode.simdPosition = [0, 0, 10]
        cameraNode.simdLook(at: [0, 0, 0], up: [0, 1, 0], localFront: [0, 0, -1])
        let sceneKitCameraMatrix = cameraNode.simdTransform
        let newLookAtCameraMatrix = LookAt(position: [0, 0, 10], target: [0, 0, 0], up: [0, 1, 0]).cameraMatrix

        #expect(newLookAtCameraMatrix == sceneKitCameraMatrix)
    }
}

