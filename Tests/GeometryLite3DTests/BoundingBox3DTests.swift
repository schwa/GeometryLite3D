@testable import GeometryLite3D
import ModelIO
import simd
import Testing

struct BoundingBox3DTests {
    @Test
    func initialization() {
        let bbox = BoundingBox3D(min: [-1, -2, -3], max: [1, 2, 3])
        #expect(bbox.min == [-1, -2, -3])
        #expect(bbox.max == [1, 2, 3])
    }

    @Test
    func transformIdentity() {
        let bbox = BoundingBox3D(min: [-1, -1, -1], max: [1, 1, 1])
        let identity = matrix_identity_float4x4
        let transformed = bbox.transformed(by: identity)

        #expect(transformed.min == bbox.min)
        #expect(transformed.max == bbox.max)
    }

    @Test
    func transformTranslation() {
        let bbox = BoundingBox3D(min: [0, 0, 0], max: [2, 2, 2])
        let translation = float4x4(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [5, 10, 15, 1]
        )
        let transformed = bbox.transformed(by: translation)

        #expect(transformed.min == [5, 10, 15])
        #expect(transformed.max == [7, 12, 17])
    }

    @Test
    func transformScale() {
        let bbox = BoundingBox3D(min: [-1, -1, -1], max: [1, 1, 1])
        let scale = float4x4(
            [2, 0, 0, 0],
            [0, 3, 0, 0],
            [0, 0, 4, 0],
            [0, 0, 0, 1]
        )
        let transformed = bbox.transformed(by: scale)

        #expect(transformed.min == [-2, -3, -4])
        #expect(transformed.max == [2, 3, 4])
    }

    @Test
    func transformRotation90Z() {
        let bbox = BoundingBox3D(min: [0, 0, 0], max: [2, 1, 1])
        let rotation = float4x4(
            [0, -1, 0, 0],
            [1, 0, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
        let transformed = bbox.transformed(by: rotation)

        #expect(abs(transformed.min.x - 0) < 1e-6)
        #expect(abs(transformed.min.y - (-2)) < 1e-6)
        #expect(abs(transformed.min.z - 0) < 1e-6)
        #expect(abs(transformed.max.x - 1) < 1e-6)
        #expect(abs(transformed.max.y - 0) < 1e-6)
        #expect(abs(transformed.max.z - 1) < 1e-6)
    }

    @Test
    func initializationFromMDLBounds() {
        var mdlBounds = MDLAxisAlignedBoundingBox()
        mdlBounds.minBounds = [-1, -2, -3]
        mdlBounds.maxBounds = [4, 5, 6]

        let bbox = BoundingBox3D(from: mdlBounds)
        #expect(bbox.min == [-1, -2, -3])
        #expect(bbox.max == [4, 5, 6])
    }

    @Test
    func initFromPoints() throws {
        let bbox = try #require(BoundingBox3D(points: [[1, -2, 3], [-1, 4, 0], [0, 0, 5]]))
        #expect(bbox.min == [-1, -2, 0])
        #expect(bbox.max == [1, 4, 5])
        #expect(BoundingBox3D(points: [SIMD3<Float>]()) == nil)
    }

    @Test
    func centerAndSize() {
        let bbox = BoundingBox3D(min: [-1, 0, 2], max: [3, 4, 4])
        #expect(bbox.center == [1, 2, 3])
        #expect(bbox.size == [4, 4, 2])
    }

    @Test
    func union() {
        let first = BoundingBox3D(min: [0, 0, 0], max: [1, 1, 1])
        let second = BoundingBox3D(min: [-1, 0.5, 0.5], max: [0.5, 2, 0.75])
        #expect(first.union(second) == BoundingBox3D(min: [-1, 0, 0], max: [1, 2, 1]))
    }

    @Test
    func contains() {
        let bbox = BoundingBox3D(min: [0, 0, 0], max: [1, 1, 1])
        #expect(bbox.contains([0.5, 0.5, 0.5]))
        #expect(bbox.contains([1, 0, 1]))
        #expect(!bbox.contains([1.01, 0.5, 0.5]))
    }
}
