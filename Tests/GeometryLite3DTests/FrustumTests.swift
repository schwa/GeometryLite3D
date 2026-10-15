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

    @Test(arguments: [PerspectiveProjection.DepthMode.reversedFinite(zClip: 1...50), .reversed(zMin: 1)])
    func reversedDepth(depthMode: PerspectiveProjection.DepthMode) {
        let frustum = frustum(depthMode: depthMode)
        #expect(frustum.intersects(cube(at: .zero)))
        #expect(!frustum.intersects(cube(at: [0, 0, 20])))
        #expect(!frustum.intersects(cube(at: [30, 0, 0])))
        #expect(!frustum.intersects(cube(at: [0, -30, 0])))
    }

    @Test
    func farPlaneCullsWithFiniteDepth() {
        let frustum = frustum(depthMode: .reversedFinite(zClip: 1...50))
        #expect(!frustum.intersects(cube(at: [0, 0, -100])))
        #expect(frustum.intersects(cube(at: [0, 0, -39])))
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
