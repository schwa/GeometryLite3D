import GeometryLite3D
import simd
import Testing

struct Ray3DTests {
    let a: SIMD3<Float> = [-1, -1, 0]
    let b: SIMD3<Float> = [1, -1, 0]
    let c: SIMD3<Float> = [0, 1, 0]

    @Test
    func directionIsNormalized() {
        #expect(Ray3D(origin: .zero, direction: [0, 0, -5]).direction == [0, 0, -1])
    }

    @Test
    func hitsTriangleWithBarycentrics() throws {
        let ray = Ray3D(origin: [0, 0, 5], direction: [0, 0, -1])
        let hit = try #require(ray.intersect(triangle: a, b, c))
        #expect(abs(hit.distance - 5) < 1e-6)
        let point = hit.barycentrics.x * a + hit.barycentrics.y * b + hit.barycentrics.z * c
        #expect(point.isApproximatelyEqual(to: [0, 0, 0], absoluteTolerance: 1e-6))
    }

    @Test
    func pointAtDistance() {
        #expect(Ray3D(origin: [1, 2, 3], direction: [0, 2, 0]).point(at: 4) == [1, 6, 3])
    }

    @Test
    func parallelRayMissesTriangle() {
        #expect(Ray3D(origin: [0, 0, 1], direction: [1, 0, 0]).intersect(triangle: a, b, c) == nil)
    }

    @Test
    func rayOutsideSecondEdgeMissesTriangle() {
        #expect(Ray3D(origin: [0, -2, 5], direction: [0, 0, -1]).intersect(triangle: a, b, c) == nil)
        #expect(Ray3D(origin: [0.9, 0.9, 5], direction: [0, 0, -1]).intersect(triangle: a, b, c) == nil)
    }

    @Test
    func missesTriangle() {
        #expect(Ray3D(origin: [5, 0, 5], direction: [0, 0, -1]).intersect(triangle: a, b, c) == nil)
        #expect(Ray3D(origin: [0, 0, 5], direction: [0, 0, 1]).intersect(triangle: a, b, c) == nil)
    }

    @Test
    func backFaceCulling() {
        let ray = Ray3D(origin: [0, 0, -5], direction: [0, 0, 1])
        #expect(ray.intersect(triangle: a, b, c) != nil)
        #expect(ray.intersect(triangle: a, b, c, cullBackFaces: true) == nil)
        #expect(Ray3D(origin: [0, 0, 5], direction: [0, 0, -1]).intersect(triangle: a, b, c, cullBackFaces: true) != nil)
    }

    @Test
    func hitsSmallTriangle() {
        let a: SIMD3<Float> = [-1e-4, -1e-4, 0]
        let b: SIMD3<Float> = [1e-4, -1e-4, 0]
        let c: SIMD3<Float> = [0, 1e-4, 0]
        #expect(Ray3D(origin: [0, 0, 1], direction: [0, 0, -1]).intersect(triangle: a, b, c) != nil)
    }

    @Test
    func hitsBoxWithFaceNormal() throws {
        let box = BoundingBox3D(min: [-1, -1, -1], max: [1, 1, 1])
        let hit = try #require(Ray3D(origin: [0, 0, 5], direction: [0, 0, -1]).intersect(box: box))
        #expect(abs(hit.distance - 4) < 1e-6)
        #expect(hit.normal == [0, 0, 1])
        let sideHit = try #require(Ray3D(origin: [-5, 0.5, 0], direction: [1, 0, 0]).intersect(box: box))
        #expect(sideHit.normal == [-1, 0, 0])
    }

    @Test
    func missesBox() {
        let box = BoundingBox3D(min: [-1, -1, -1], max: [1, 1, 1])
        #expect(Ray3D(origin: [0, 5, 5], direction: [0, 0, -1]).intersect(box: box) == nil)
        #expect(Ray3D(origin: [0, 0, 5], direction: [0, 0, 1]).intersect(box: box) == nil)
    }

    @Test(arguments: [false, true])
    func rayFromViewCenterLooksForward(reversedDepth: Bool) {
        let view = LookAt(position: [0, 0, 10], target: .zero, up: [0, 1, 0]).viewMatrix
        let depthMode: PerspectiveProjection.DepthMode = reversedDepth ? .reversed(zClip: 1...100) : .standard(zClip: 1...100)
        let projection = PerspectiveProjection(verticalAngleOfView: .degrees(60), depthMode: depthMode).projectionMatrix(aspectRatio: 1)
        let ray = Ray3D(viewPoint: [50, 50], viewSize: [100, 100], viewMatrix: view, projectionMatrix: projection, reversedDepth: reversedDepth)
        #expect(ray.direction.isApproximatelyEqual(to: [0, 0, -1], absoluteTolerance: 1e-5))
        #expect(ray.origin.isApproximatelyEqual(to: [0, 0, 9], absoluteTolerance: 1e-4))
    }

    @Test
    func rayFromViewTopLeftPointsUpLeft() {
        let view = float4x4.identity
        let projection = PerspectiveProjection(verticalAngleOfView: .degrees(90), depthMode: .standard(zClip: 1...100)).projectionMatrix(aspectRatio: 1)
        let ray = Ray3D(viewPoint: [0, 0], viewSize: [100, 100], viewMatrix: view, projectionMatrix: projection)
        #expect(ray.direction.isApproximatelyEqual(to: normalize(SIMD3<Float>(-1, 1, -1)), absoluteTolerance: 1e-5))
    }
}
