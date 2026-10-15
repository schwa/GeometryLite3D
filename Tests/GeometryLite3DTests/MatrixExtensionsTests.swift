import GeometryLite3D
import simd
import Testing

struct MatrixExtensionsTests {
    @Test
    func normalMatrixOfRotationIsRotation() {
        let matrix = float4x4(yRotation: .degrees(30)) * float4x4(translation: [1, 2, 3])
        let normalMatrix = matrix.normalMatrix
        let upperLeft = matrix.upperLeft3x3
        for column in 0..<3 {
            #expect(normalMatrix[column].isApproximatelyEqual(to: upperLeft[column], absoluteTolerance: 1e-6))
        }
    }

    @Test
    func isMirroring() {
        #expect(!float4x4.identity.isMirroring)
        #expect(!float4x4(scale: [-1, -1, 1]).isMirroring)
        #expect(float4x4(scale: [-1, 1, 1]).isMirroring)
        #expect((float4x4(yRotation: .degrees(45)) * float4x4(scale: [1, 1, -2])).isMirroring)
    }

    @Test
    func normalMatrixKeepsNormalsPerpendicularUnderNonUniformScale() {
        let matrix = float4x4(scale: [2, 1, 1])
        let tangent = normalize(SIMD3<Float>(1, 1, 0))
        let normal = normalize(SIMD3<Float>(1, -1, 0))
        let transformedTangent = matrix.upperLeft3x3 * tangent
        let transformedNormal = matrix.normalMatrix * normal
        #expect(abs(dot(transformedTangent, transformedNormal)) < 1e-6)
    }

    @Test
    func doubleHelpersMatchFloat() {
        let translation: SIMD3<Double> = [1, 2, 3]
        let scale: SIMD3<Double> = [2, -1, 0.5]
        let matrix = double4x4(translation: translation) * double4x4(scale: scale)
        let floatMatrix = float4x4(translation: SIMD3<Float>(translation)) * float4x4(scale: SIMD3<Float>(scale))

        #expect(matrix.translation == translation)
        #expect(matrix.isMirroring == floatMatrix.isMirroring)
        #expect(matrix.canInvert)
        #expect(double4x4.identity == double4x4(diagonal: [1, 1, 1, 1]))
        for column in 0..<3 {
            #expect(SIMD3<Float>(matrix.upperLeft3x3[column]) == floatMatrix.upperLeft3x3[column])
            #expect(SIMD3<Float>(matrix.normalMatrix[column]).isApproximatelyEqual(to: floatMatrix.normalMatrix[column], absoluteTolerance: 1e-6))
        }

        var moved = matrix
        moved.translation = [4, 5, 6]
        #expect(moved.columns.3 == [4, 5, 6, 1])
    }
}
