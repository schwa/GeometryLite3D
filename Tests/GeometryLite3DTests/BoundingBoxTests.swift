import Testing
import simd
import ModelIO
@testable import GeometryLite3D

struct BoundingBoxTests {
    @Test
    func initialization() {
        let bbox = BoundingBox(min: [-1, -2, -3], max: [1, 2, 3])
        #expect(bbox.min == [-1, -2, -3])
        #expect(bbox.max == [1, 2, 3])
    }

    @Test
    func transformIdentity() {
        let bbox = BoundingBox(min: [-1, -1, -1], max: [1, 1, 1])
        let identity = matrix_identity_float4x4
        let transformed = bbox.transformed(by: identity)

        #expect(transformed.min == bbox.min)
        #expect(transformed.max == bbox.max)
    }

    @Test
    func transformTranslation() {
        let bbox = BoundingBox(min: [0, 0, 0], max: [2, 2, 2])
        let translation = matrix_float4x4(
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
        let bbox = BoundingBox(min: [-1, -1, -1], max: [1, 1, 1])
        let scale = matrix_float4x4(
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
        let bbox = BoundingBox(min: [0, 0, 0], max: [2, 1, 1])
        let rotation = matrix_float4x4(
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

        let bbox = BoundingBox(from: mdlBounds)
        #expect(bbox.min == [-1, -2, -3])
        #expect(bbox.max == [4, 5, 6])
    }
}
