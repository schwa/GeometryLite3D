import Testing
import simd
@testable import GeometryLite3D

struct SIMDExtensionsTests {
    @Test
    func float4x4Identity() {
        let identity = float4x4.identity
        #expect(identity[0][0] == 1)
        #expect(identity[1][1] == 1)
        #expect(identity[2][2] == 1)
        #expect(identity[3][3] == 1)
        #expect(identity[0][1] == 0)
    }

    @Test
    func float4x4XRotation() {
        let matrix = float4x4(xRotation: AngleF(degrees: 90))
        let point = matrix * SIMD4<Float>(0, 1, 0, 1)
        #expect(abs(point.x) < 1e-6)
        #expect(abs(point.y) < 1e-6)
        #expect(abs(point.z + 1) < 1e-6)
    }

    @Test
    func float4x4YRotation() {
        let matrix = float4x4(yRotation: AngleF(degrees: 90))
        let point = matrix * SIMD4<Float>(1, 0, 0, 1)
        #expect(abs(point.x) < 1e-6)
        #expect(abs(point.y) < 1e-6)
        #expect(abs(point.z - 1) < 1e-6)
    }

    @Test
    func float4x4ZRotation() {
        let matrix = float4x4(zRotation: AngleF(degrees: 90))
        let point = matrix * SIMD4<Float>(1, 0, 0, 1)
        #expect(abs(point.x) < 1e-6)
        #expect(abs(point.y + 1) < 1e-6)
        #expect(abs(point.z) < 1e-6)
    }

    @Test
    func float4x4Translation() {
        let matrix = float4x4(translation: [10, 20, 30])
        #expect(matrix[3][0] == 10)
        #expect(matrix[3][1] == 20)
        #expect(matrix[3][2] == 30)
        #expect(matrix[3][3] == 1)

        #expect(matrix.translation == [10, 20, 30])
    }

    @Test
    func float4x4TranslationProperty() {
        var matrix = float4x4.identity
        matrix.translation = [5, 10, 15]
        #expect(matrix[3][0] == 5)
        #expect(matrix[3][1] == 10)
        #expect(matrix[3][2] == 15)
    }

    @Test
    func float4x4Scale() {
        let matrix = float4x4(scale: [2, 3, 4])
        #expect(matrix[0][0] == 2)
        #expect(matrix[1][1] == 3)
        #expect(matrix[2][2] == 4)
        #expect(matrix[3][3] == 1)
    }

    @Test
    func float4x4CanInvert() {
        let identity = float4x4.identity
        #expect(identity.canInvert == true)

        let singular = float4x4(
            [1, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        )
        #expect(singular.canInvert == false)
    }

    @Test
    func float4x4UpperLeft() {
        let matrix = float4x4(
            [1, 2, 3, 4],
            [5, 6, 7, 8],
            [9, 10, 11, 12],
            [13, 14, 15, 16]
        )
        let upperLeft = matrix.upperLeft
        #expect(upperLeft.columns.0 == [1, 2, 3])
        #expect(upperLeft.columns.1 == [5, 6, 7])
        #expect(upperLeft.columns.2 == [9, 10, 11])
    }

    @Test
    func simd3Unit() {
        #expect(SIMD3<Float>.unit == [1, 1, 1])
    }

    @Test
    func simd3Normalized() {
        let vector = SIMD3<Float>(3, 0, 4)
        let normalized = vector.normalized
        #expect(abs(simd_length(normalized) - 1) < 1e-6)
        #expect(abs(normalized.x - 0.6) < 1e-6)
        #expect(abs(normalized.z - 0.8) < 1e-6)
    }

    @Test
    func simd3XY() {
        var vector = SIMD3<Float>(1, 2, 3)
        #expect(vector.xy == [1, 2])

        vector.xy = [4, 5]
        #expect(vector == [4, 5, 3])
    }

    @Test
    func simd3Map() {
        let vector = SIMD3<Float>(1, 2, 3)
        let doubled = vector.map { $0 * 2 }
        #expect(doubled == [2, 4, 6])
    }

    @Test
    func simd4XYZ() {
        var vector = SIMD4<Float>(1, 2, 3, 4)
        #expect(vector.xyz == [1, 2, 3])

        vector.xyz = [5, 6, 7]
        #expect(vector == [5, 6, 7, 4])
    }

    @Test
    func simd4Map() {
        let vector = SIMD4<Float>(1, 2, 3, 4)
        let squared = vector.map { $0 * $0 }
        #expect(squared == [1, 4, 9, 16])
    }

    @Test
    func simd4Scalars() {
        let vector = SIMD4<Float>(10, 20, 30, 40)
        #expect(vector.scalars == [10, 20, 30, 40])
    }

    @Test
    func simdQuatfIdentity() {
        let identity = simd_quatf.identity
        #expect(identity.imag == [0, 0, 0])
        #expect(identity.real == 1)
    }
}