import GeometryLite3D
import simd
import Testing

struct FrustumTests {
    func frustum(depthMode: PerspectiveProjection.DepthMode) -> Frustum {
        let view = LookAt(position: [0, 0, 10], target: .zero, up: [0, 1, 0]).viewMatrix
        let projection = PerspectiveProjection(verticalAngleOfView: .degrees(60), depthMode: depthMode).projectionMatrix(aspectRatio: 1)
        return Frustum(viewProjection: projection * view)
    }

    func cube(at center: SIMD3<Float>) -> BoundingBox3D {
        BoundingBox3D(min: center - 0.5, max: center + 0.5)
    }

    @Test(arguments: [PerspectiveProjection.DepthMode.reversed(zClip: 1...50), .reversedInfinite(zNear: 1)])
    func reversedDepth(depthMode: PerspectiveProjection.DepthMode) {
        let frustum = frustum(depthMode: depthMode)
        #expect(frustum.intersects(cube(at: .zero)))
        #expect(!frustum.intersects(cube(at: [0, 0, 20])))
        #expect(!frustum.intersects(cube(at: [30, 0, 0])))
        #expect(!frustum.intersects(cube(at: [0, -30, 0])))
    }

    @Test
    func standardDepthKeepsBoxesJustPastNear() {
        let frustum = frustum(depthMode: .standard(zClip: 1...50))
        #expect(frustum.intersects(BoundingBox3D(min: [-0.1, -0.1, 8.5], max: [0.1, 0.1, 8.8])))
        #expect(!frustum.intersects(BoundingBox3D(min: [-0.1, -0.1, 9.2], max: [0.1, 0.1, 9.5])))
        #expect(!frustum.intersects(cube(at: [0, 0, -100])))
    }

    @Test
    func farPlaneCullsWithFiniteDepth() {
        let frustum = frustum(depthMode: .reversed(zClip: 1...50))
        #expect(!frustum.intersects(cube(at: [0, 0, -100])))
        #expect(frustum.intersects(cube(at: [0, 0, -39])))
    }

    @Test
    func namedPlanesMatchClipPlanes() {
        let frustum = Frustum(viewProjection: .identity)
        #expect(frustum.left == [1, 0, 0, 1])
        #expect(frustum.right == [-1, 0, 0, 1])
        #expect(frustum.bottom == [0, 1, 0, 1])
        #expect(frustum.top == [0, -1, 0, 1])
        #expect(frustum.near == [0, 0, 1, 0])
        #expect(frustum.far == [0, 0, -1, 1])
        #expect(frustum.planes == [frustum.left, frustum.right, frustum.bottom, frustum.top, frustum.near, frustum.far])
    }

    @Test
    func orthographic() {
        let projection = OrthographicProjection(halfHeight: 2, depthMode: .reversed(zClip: 0.1...10)).projectionMatrix(aspectRatio: 1)
        let frustum = Frustum(viewProjection: projection)
        #expect(frustum.intersects(cube(at: [0, 0, -5])))
        #expect(frustum.intersects(cube(at: [2.4, 0, -5])))
        #expect(!frustum.intersects(cube(at: [3, 0, -5])))
        #expect(!frustum.intersects(cube(at: [0, 0, 1])))
        #expect(!frustum.intersects(cube(at: [0, 0, -11])))
    }
}
