import GeometryLite3D
import simd
import Spatial
import Testing

struct SpatialGroundTruthTests {
    private func rect(_ box: BoundingBox3D) -> Rect3D {
        let min = SIMD3<Double>(box.min)
        let max = SIMD3<Double>(box.max)
        return Rect3D(origin: Point3D(vector: min), size: Size3D(vector: max - min))
    }

    private func box(_ rect: Rect3D) -> BoundingBox3D {
        BoundingBox3D(min: SIMD3<Float>(rect.min.vector), max: SIMD3<Float>(rect.max.vector))
    }

    private func float4x4(_ matrix: simd_double4x4) -> simd_float4x4 {
        simd_float4x4(SIMD4<Float>(matrix.columns.0), SIMD4<Float>(matrix.columns.1), SIMD4<Float>(matrix.columns.2), SIMD4<Float>(matrix.columns.3))
    }

    private func affine(_ transform: Transform3D) -> AffineTransform3D {
        AffineTransform3D(
            scale: Size3D(vector: SIMD3<Double>(transform.scale)),
            rotation: Rotation3D(simd_quatd(vector: SIMD4<Double>(transform.rotation.vector))),
            translation: Vector3D(vector: SIMD3<Double>(transform.translation))
        )
    }

    let first = BoundingBox3D(min: [-1, 0, 2], max: [3, 4, 4])
    let second = BoundingBox3D(min: [2, -3, 0], max: [5, 1, 3])

    @Test
    func boundingBoxCenterAndSize() {
        let spatial = rect(first)
        #expect(first.center == SIMD3<Float>(spatial.center.vector))
        #expect(first.size == SIMD3<Float>(spatial.size.vector))
    }

    @Test
    func boundingBoxUnion() {
        #expect(first.union(second) == box(rect(first).union(rect(second))))
    }

    @Test(arguments: [SIMD3<Float>(0, 1, 3), [3, 4, 4], [3.1, 1, 3], [-2, 0, 0]])
    func boundingBoxContains(point: SIMD3<Float>) {
        #expect(first.contains(point) == rect(first).contains(point: Point3D(vector: SIMD3<Double>(point))))
    }

    @Test
    func boundingBoxTransformed() {
        let transform = Transform3D(translation: [1, 2, 3], rotation: simd_quatf(angle: 0.6, axis: normalize(SIMD3<Float>(1, 2, 0))), scale: [2, 1, 0.5])
        let ours = first.transformed(by: transform.matrix)
        let spatial = box(rect(first).applying(affine(transform)))
        #expect(ours.min.isApproximatelyEqual(to: spatial.min, absoluteTolerance: 1e-5))
        #expect(ours.max.isApproximatelyEqual(to: spatial.max, absoluteTolerance: 1e-5))
    }

    @Test
    func transformMatrix() {
        let transform = Transform3D(translation: [1, -2, 3], rotation: simd_quatf(angle: 0.7, axis: normalize(SIMD3<Float>(1, 1, 0))), scale: [1, 2, 3])
        #expect(transform.matrix.isApproximatelyEqual(to: float4x4(affine(transform).matrix4x4), absoluteTolerance: 1e-5))
    }

    @Test
    func transformInterpolationRotationMatchesSlerp() throws {
        let start = Transform3D(rotation: simd_quatf(angle: 0.2, axis: [0, 1, 0]))
        let end = Transform3D(rotation: simd_quatf(angle: 2.5, axis: normalize(SIMD3<Float>(1, 1, 1))))
        let ours = start.interpolated(to: end, amount: 0.3).rotation
        let startRotation = try #require(affine(start).rotation)
        let endRotation = try #require(affine(end).rotation)
        let spatial = Rotation3D.slerp(from: startRotation, to: endRotation, t: 0.3)
        #expect(ours.isApproximatelyEqual(to: simd_quatf(spatial), absoluteTolerance: 1e-5))
    }
}
