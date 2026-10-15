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
    func normalMatrixKeepsNormalsPerpendicularUnderNonUniformScale() {
        let matrix = float4x4(scale: [2, 1, 1])
        let tangent = normalize(SIMD3<Float>(1, 1, 0))
        let normal = normalize(SIMD3<Float>(1, -1, 0))
        let transformedTangent = matrix.upperLeft3x3 * tangent
        let transformedNormal = matrix.normalMatrix * normal
        #expect(abs(dot(transformedTangent, transformedNormal)) < 1e-6)
    }
}
