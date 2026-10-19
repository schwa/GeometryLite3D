import Foundation
import GeometryLite3D
import simd
import Testing

struct TriangleTests {
    let a: SIMD3<Float> = [0, 0, 0]
    let b: SIMD3<Float> = [1, 0, 0]
    let c: SIMD3<Float> = [0, 1, 0]

    func check(_ p: SIMD3<Float>, point expected: SIMD3<Float>, barycentrics expectedBarycentrics: SIMD3<Float>) {
        let result = closestPoint(onTriangle: a, b, c, to: p)
        #expect(result.point.isApproximatelyEqual(to: expected, absoluteTolerance: 1e-6))
        #expect(result.barycentrics.isApproximatelyEqual(to: expectedBarycentrics, absoluteTolerance: 1e-6))
        let reconstructed = result.barycentrics.x * a + result.barycentrics.y * b + result.barycentrics.z * c
        #expect(reconstructed.isApproximatelyEqual(to: result.point, absoluteTolerance: 1e-6))
    }

    @Test
    func closestPointVertices() {
        check([-1, -1, 2], point: a, barycentrics: [1, 0, 0])
        check([2, -1, -3], point: b, barycentrics: [0, 1, 0])
        check([-1, 2, 1], point: c, barycentrics: [0, 0, 1])
    }

    @Test
    func closestPointEdges() {
        check([0.25, -1, 1], point: [0.25, 0, 0], barycentrics: [0.75, 0.25, 0])
        check([-1, 0.5, 1], point: [0, 0.5, 0], barycentrics: [0.5, 0, 0.5])
        check([1, 1, 1], point: [0.5, 0.5, 0], barycentrics: [0, 0.5, 0.5])
    }

    @Test
    func closestPointFace() {
        check([0.25, 0.25, 3], point: [0.25, 0.25, 0], barycentrics: [0.5, 0.25, 0.25])
    }

    @Test
    func closestPointDegenerateTriangles() {
        let collinear = closestPoint(onTriangle: [0, 0, 0], [1, 0, 0], [2, 0, 0], to: [1.5, 1, 0])
        #expect(collinear.point.isApproximatelyEqual(to: [1.5, 0, 0], absoluteTolerance: 1e-6))
        #expect(!collinear.barycentrics.x.isNaN && !collinear.barycentrics.y.isNaN && !collinear.barycentrics.z.isNaN)
        let point = closestPoint(onTriangle: [1, 1, 1], [1, 1, 1], [1, 1, 1], to: [0, 0, 0])
        #expect(point.point == [1, 1, 1])
    }

    // Unit cube [-1, 1]^3, outward-wound.
    var cubeTriangles: [[SIMD3<Float>]] {
        var triangles: [[SIMD3<Float>]] = []
        for axis in 0..<3 {
            for sign: Float in [-1, 1] {
                var normal = SIMD3<Float>.zero
                normal[axis] = sign
                var u = SIMD3<Float>.zero
                u[(axis + 1) % 3] = 1
                let v = cross(normal, u)
                let corners = [normal - u - v, normal + u - v, normal + u + v, normal - u + v]
                triangles.append([corners[0], corners[1], corners[2]])
                triangles.append([corners[0], corners[2], corners[3]])
            }
        }
        return triangles
    }

    @Test
    func solidAngleOfCube() {
        let triangles = cubeTriangles
        for t in triangles {
            #expect(dot(cross(t[1] - t[0], t[2] - t[0]), t[0]) > 0)
        }
        let inside = triangles.reduce(0) { $0 + solidAngle(ofTriangle: $1[0], $1[1], $1[2], from: [0.1, -0.2, 0.3]) }
        #expect(abs(inside - 4 * .pi) < 1e-4)
        let outside = triangles.reduce(0) { $0 + solidAngle(ofTriangle: $1[0], $1[1], $1[2], from: [3, 0.5, -2]) }
        #expect(abs(outside) < 1e-4)
    }

    @Test
    func solidAngleOfOneFaceFromCenter() {
        let triangles = cubeTriangles
        let face = solidAngle(ofTriangle: triangles[0][0], triangles[0][1], triangles[0][2], from: .zero)
            + solidAngle(ofTriangle: triangles[1][0], triangles[1][1], triangles[1][2], from: .zero)
        #expect(abs(face - 4 * .pi / 6) < 1e-5)
    }
}
