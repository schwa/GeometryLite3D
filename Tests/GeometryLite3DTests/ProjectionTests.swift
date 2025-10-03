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
//        cameraNode.simdPosition = [0, 0, 10]
//        cameraNode.simdLook(at: [0, 0, 0], up: [0, 1, 0], localFront: [0, 0, -1])
        print("#############")
        float4x4(camera.projectionTransform(withViewportSize: CGSize(width: 2, height: 1))).dump()
        print("#############")
        NewPerspectiveProjection(verticalAngleOfView: .radians(Float(camera.fieldOfView)), zClip: 1...100, reverseZ: false).projectionMatrix(width: 2, height: 1).dump()

    }

}

extension float4x4 {
    var scalars: [Float] {
        withUnsafeBytes(of: self) { buffer in
            Array(buffer.bindMemory(to: Float.self))
        }
    }
}

extension float4x4 {
    func dump() {
        let s = (0..<4).map { row in
            (0..<4).map { column in
                let value = self[column, row]
                return value.formatted(.number.precision(.fractionLength(4)))
            }
            .joined(separator: ", ")
        }
        .joined(separator: "\n")
        print(s)
    }
}
