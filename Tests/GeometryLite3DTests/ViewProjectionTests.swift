@testable import GeometryLite3D
import simd
import Testing

struct ViewProjectionTests {
    static let depthModes: [PerspectiveProjection.DepthMode] = [
        .standard(zClip: 1...100),
        .reversed(zClip: 1...100),
        .reversedInfinite(zNear: 1)
    ]

    func makeViewProjection(_ depthMode: PerspectiveProjection.DepthMode) -> ViewProjection {
        ViewProjection(
            viewMatrix: LookAt(position: [0, 0, 10], target: .zero, up: [0, 1, 0]).viewMatrix,
            projection: PerspectiveProjection(verticalAngleOfView: .degrees(60), depthMode: depthMode),
            viewSize: [200, 100]
        )
    }

    @Test
    func projectionsReportDepthDirection() {
        #expect(!PerspectiveProjection(depthMode: .standard(zClip: 1...10)).isReversedDepth)
        #expect(PerspectiveProjection(depthMode: .reversed(zClip: 1...10)).isReversedDepth)
        #expect(PerspectiveProjection(depthMode: .reversedInfinite(zNear: 1)).isReversedDepth)
        #expect(!OrthographicProjection(depthMode: .standard(zClip: 1...10)).isReversedDepth)
        #expect(OrthographicProjection(depthMode: .reversed(zClip: 1...10)).isReversedDepth)
    }

    @Test(arguments: depthModes)
    func nearDepthMatchesDepthDirection(depthMode: PerspectiveProjection.DepthMode) {
        let viewProjection = makeViewProjection(depthMode)
        #expect(viewProjection.nearDepth == (viewProjection.isReversedDepth ? 1 : 0))
    }

    @Test(arguments: depthModes)
    func rayFromCenterStartsAtNearPlane(depthMode: PerspectiveProjection.DepthMode) {
        let ray = makeViewProjection(depthMode).ray(through: [100, 50])
        #expect(ray.direction.isApproximatelyEqual(to: [0, 0, -1], absoluteTolerance: 1e-5))
        #expect(ray.origin.isApproximatelyEqual(to: [0, 0, 9], absoluteTolerance: 1e-3))
    }

    @Test(arguments: depthModes)
    func projectThenUnprojectRoundTrips(depthMode: PerspectiveProjection.DepthMode) throws {
        let viewProjection = makeViewProjection(depthMode)
        let world: SIMD3<Float> = [1, -0.5, 2]
        let projected = try #require(viewProjection.project(world))
        #expect(viewProjection.unproject(projected).isApproximatelyEqual(to: world, absoluteTolerance: 1e-3))
    }

    @Test(arguments: depthModes)
    func projectUsesTopLeftViewOrigin(depthMode: PerspectiveProjection.DepthMode) throws {
        let viewProjection = makeViewProjection(depthMode)
        let center = try #require(viewProjection.project(.zero))
        #expect(center.xy.isApproximatelyEqual(to: [100, 50], absoluteTolerance: 1e-3))
        let above = try #require(viewProjection.project([0, 1, 0]))
        #expect(above.y < 50)
    }

    @Test
    func projectBehindCameraIsNil() {
        #expect(makeViewProjection(.standard(zClip: 1...100)).project([0, 0, 20]) == nil)
    }

    @Test(arguments: depthModes)
    func frustumCullsBoxBehindCamera(depthMode: PerspectiveProjection.DepthMode) {
        let frustum = makeViewProjection(depthMode).frustum
        #expect(frustum.intersects(BoundingBox3D(min: [-1, -1, -1], max: [1, 1, 1])))
        #expect(!frustum.intersects(BoundingBox3D(min: [-1, -1, 20], max: [1, 1, 22])))
    }
}
