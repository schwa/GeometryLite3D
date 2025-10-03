import Testing
import simd
@testable import GeometryLite3D

struct DecompositionTests {
    @Test
    func transformComponentsIdentity() {
        let identity = TransformComponents.identity
        #expect(identity.perspective == [0, 0, 0, 1])
        #expect(identity.translate == .zero)
        #expect(identity.scale == .one)
        #expect(identity.skew == Skew.zero)
        #expect(identity.rotation == .identity)
    }

    @Test
    func skewInitialization() {
        let skew = Skew(xy: 0.1, xz: 0.2, yz: 0.3)
        #expect(skew.xy == 0.1)
        #expect(skew.xz == 0.2)
        #expect(skew.yz == 0.3)

        let zero = Skew.zero
        #expect(zero.xy == 0)
        #expect(zero.xz == 0)
        #expect(zero.yz == 0)
    }

    @Test
    func decomposeIdentityMatrix() {
        let identity = matrix_identity_float4x4
        let components = identity.decompose

        #expect(components != nil)
        if let components = components {
            #expect(components.perspective == [0, 0, 0, 1])
            #expect(components.translate == .zero)
            #expect(components.scale == .one)
            #expect(components.skew == Skew.zero)
            #expect(abs(components.rotation.angle) < 1e-6)
        }
    }

    @Test
    func decomposeTranslationMatrix() {
        let translation = float4x4(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [10, 20, 30, 1]
        )
        let components = translation.decompose

        #expect(components != nil)
        if let components = components {
            #expect(components.translate == [10, 20, 30])
            #expect(components.scale == .one)
            #expect(components.skew == Skew.zero)
        }
    }

    @Test
    func decomposeScaleMatrix() {
        let scale = float4x4(
            [2, 0, 0, 0],
            [0, 3, 0, 0],
            [0, 0, 4, 0],
            [0, 0, 0, 1]
        )
        let components = scale.decompose

        #expect(components != nil)
        if let components = components {
            #expect(components.translate == .zero)
            #expect(components.scale == [2, 3, 4])
            #expect(components.skew == Skew.zero)
        }
    }

    @Test
    func decomposeRotationMatrix() {
        let angle: Float = .pi / 4
        let rotation = float4x4(simd_quatf(angle: angle, axis: [0, 0, 1]))
        let components = rotation.decompose

        #expect(components != nil)
        if let components = components {
            #expect(components.translate == .zero)
            #expect(abs(components.scale.x - 1) < 1e-6)
            #expect(abs(components.scale.y - 1) < 1e-6)
            #expect(abs(components.scale.z - 1) < 1e-6)
            #expect(abs(components.rotation.angle - angle) < 1e-6)
        }
    }

    @Test
    func decomposeCombinedTransform() {
        let translation = float4x4(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [5, 10, 15, 1]
        )
        let scale = float4x4(
            [2, 0, 0, 0],
            [0, 2, 0, 0],
            [0, 0, 2, 0],
            [0, 0, 0, 1]
        )
        let combined = translation * scale
        let components = combined.decompose

        #expect(components != nil)
        if let components = components {
            #expect(components.translate == [5, 10, 15])
            #expect(components.scale == [2, 2, 2])
        }
    }

    @Test
    func decomposeMatrixWithPerspective() {
        let matrix = float4x4(
            [1, 0, 0, 0.2],
            [0, 1, 0, -0.3],
            [0, 0, 1, 0.4],
            [0, 0, 0, 1]
        )
        let components = matrix.decompose

        #expect(components != nil)
        if let components = components {
            #expect(abs(components.perspective.x - 0.2) < 1e-6)
            #expect(abs(components.perspective.y + 0.3) < 1e-6)
            #expect(abs(components.perspective.z - 0.4) < 1e-6)
            #expect(abs(components.perspective.w - 1) < 1e-6)
            #expect(components.translate == .zero)
            #expect(components.scale == .one)
            #expect(components.skew == Skew.zero)
        }
    }

    @Test
    func decomposeMatrixWithZeroWReturnsNil() {
        let matrix = float4x4(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 0]
        )
        #expect(matrix.decompose == nil)
    }

    @Test
    func decomposeNonInvertiblePerspectiveReturnsNil() {
        let matrix = float4x4(
            [1, 0, 0, 1],
            [1, 0, 0, 0],
            [1, 0, 0, 0],
            [0, 0, 0, 1]
        )
        #expect(matrix.decompose == nil)
    }

    @Test
    func decomposeSingularMatrix() {
        let singular = float4x4(
            [1, 0, 0, 0],
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 0, 1]
        )
        #expect(singular.decompose == nil)
    }

    @Test
    func decomposeMatrixWithSingularUpper3x3ReturnsNil() {
        let matrix = float4x4(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 1]
        )
        #expect(matrix.decompose == nil)
    }

    @Test
    func eulerFromQuaternion() {
        let quat = simd_quatf(angle: Float.pi / 2, axis: [0, 1, 0])
        let euler = Euler(quat)

        #expect(abs(euler.pitch - Float.pi / 2) < 1e-5)
    }

    @Test
    func decomposeMatrixWithSkew() {
        let matrix = float4x4(
            [1, 0, 0, 0],
            [0.5, 1, 0, 0],
            [0.25, 0.75, 1, 0],
            [0, 0, 0, 1]
        )
        let components = matrix.decompose

        #expect(components != nil)
        if let components = components {
            #expect(abs(components.skew.xy - 0.5) < 1e-6)
            #expect(abs(components.skew.xz - 0.25) < 1e-6)
            #expect(abs(components.skew.yz - 0.75) < 1e-6)
            #expect(components.scale == .one)
            #expect(components.translate == .zero)
        }
    }

    @Test
    func decomposeNegativeScaleMatrix() {
        let matrix = float4x4(
            [-2, 0, 0, 0],
            [0, 3, 0, 0],
            [0, 0, 4, 0],
            [0, 0, 0, 1]
        )
        let components = matrix.decompose

        #expect(components != nil)
        if let components = components {
            #expect(components.translate == .zero)
            #expect(abs(components.scale.x + 2) < 1e-6)
            #expect(abs(components.scale.y + 3) < 1e-6)
            #expect(abs(components.scale.z + 4) < 1e-6)
            #expect(abs(components.rotation.angle - Float.pi) < 1e-5)
        }
    }

    @Test
    func decomposePiRotationChoosesXAxisBranch() {
        let matrix = float4x4(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, -1, 0, 0),
            SIMD4<Float>(0, 0, -1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )

        let components = matrix.decompose
        #expect(components != nil)
        if let components = components {
            #expect(components.scale == .one)
            #expect(abs(components.rotation.angle - Float.pi) < 1e-5)
            let axis = components.rotation.axis
            #expect(abs(abs(axis.x) - 1) < 1e-5)
            #expect(abs(axis.y) < 1e-5)
            #expect(abs(axis.z) < 1e-5)
        }
    }

    @Test
    func decomposePiRotationChoosesYAxisBranch() {
        let matrix = float4x4(
            SIMD4<Float>(-1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, -1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )

        let components = matrix.decompose
        #expect(components != nil)
        if let components = components {
            #expect(components.scale == .one)
            #expect(abs(components.rotation.angle - Float.pi) < 1e-5)
            let axis = components.rotation.axis
            #expect(abs(axis.x) < 1e-5)
            #expect(abs(abs(axis.y) - 1) < 1e-5)
            #expect(abs(axis.z) < 1e-5)
        }
    }

    @Test
    func decomposePiRotationChoosesZAxisBranch() {
        let matrix = float4x4(
            SIMD4<Float>(-1, 0, 0, 0),
            SIMD4<Float>(0, -1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )

        let components = matrix.decompose
        #expect(components != nil)
        if let components = components {
            #expect(components.scale == .one)
            #expect(abs(components.rotation.angle - Float.pi) < 1e-5)
            let axis = components.rotation.axis
            #expect(abs(axis.x) < 1e-5)
            #expect(abs(axis.y) < 1e-5)
            #expect(abs(abs(axis.z) - 1) < 1e-5)
        }
    }

    @Test
    func scalingVectorToDesiredLength() {
        var vector = SIMD3<Float>(3, 0, 0)
        vector.scale(to: 6)
        #expect(vector == SIMD3<Float>(6, 0, 0))

        var diagonal = SIMD3<Float>(1, 1, 1)
        diagonal.scale(to: 5)
        #expect(abs(length(diagonal) - 5) < 1e-5)
    }
}
