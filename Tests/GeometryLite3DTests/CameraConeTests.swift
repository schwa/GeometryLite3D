@testable import GeometryLite3D
import simd
import SwiftUI
import Testing

struct CameraConeTests {
    @Test
    func parametersInitialization() {
        let params = CameraConeParameters(
            centerA: [0, 0, 0],
            radiusA: 1,
            radiusB: 2,
            axis: [0, 1, 0],
            distance: 10
        )

        #expect(params.centerA == [0, 0, 0])
        #expect(params.radiusA == 1)
        #expect(params.radiusB == 2)
        #expect(params.axis == [0, 1, 0])
        #expect(params.distance == 10)
    }

    @Test
    func parametersInitializationFromCenters() {
        let params = CameraConeParameters(
            centerA: [0, 0, 0],
            centerB: [0, 10, 0],
            radiusA: 1,
            radiusB: 2
        )

        #expect(params.centerA == [0, 0, 0])
        #expect(params.centerB == [0, 10, 0])
        #expect(params.radiusA == 1)
        #expect(params.radiusB == 2)
        #expect(abs(params.distance - 10) < 1e-6)
        #expect(params.axis == [0, 1, 0])
    }

    @Test
    func centerBComputed() {
        let params = CameraConeParameters(
            centerA: [1, 2, 3],
            radiusA: 1,
            radiusB: 2,
            axis: [0, 0, 1],
            distance: 5
        )

        let centerB = params.centerB
        #expect(centerB == [1, 2, 8])
    }

    @Test
    func cameraPositionAtBase() {
        let params = CameraConeParameters(
            centerA: [0, 0, 0],
            radiusA: 1,
            radiusB: 2,
            axis: [0, 1, 0],
            distance: 10
        )

        let pos = params.cameraPosition(angle: 0, t: 0)
        #expect(abs(pos.x - 1) < 1e-6)
        #expect(abs(pos.y) < 1e-6)
        #expect(abs(pos.z) < 1e-6)
    }

    @Test
    func cameraPositionAtTop() {
        let params = CameraConeParameters(
            centerA: [0, 0, 0],
            radiusA: 1,
            radiusB: 2,
            axis: [0, 1, 0],
            distance: 10
        )

        let pos = params.cameraPosition(angle: 0, t: 1)
        #expect(abs(pos.x - 2) < 1e-6)
        #expect(abs(pos.y - 10) < 1e-6)
        #expect(abs(pos.z) < 1e-6)
    }

    @Test
    func cameraPositionRotation() {
        let params = CameraConeParameters(
            centerA: [0, 0, 0],
            radiusA: 1,
            radiusB: 1,
            axis: [0, 1, 0],
            distance: 10
        )

        let pos90 = params.cameraPosition(angle: Float.pi / 2, t: 0.5)
        #expect(abs(pos90.x) < 1e-6)
        #expect(abs(pos90.y - 5) < 1e-6)
        #expect(abs(pos90.z - 1) < 1e-6)
    }

    @Test
    func cameraConeInitialization() {
        let params = CameraConeParameters(
            centerA: [0, 0, 0],
            radiusA: 1,
            radiusB: 2,
            axis: [0, 1, 0],
            distance: 10
        )

        let cone = CameraCone(
            parameters: params,
            rotation: Angle(degrees: 45),
            height: 0.5
        )

        #expect(cone.parameters == params)
        #expect(cone.rotation == Angle(degrees: 45))
        #expect(cone.height == 0.5)
    }

    @Test
    func cameraPositionClampsTBetweenZeroAndOne() {
        let params = CameraConeParameters(
            centerA: [0, 0, 0],
            radiusA: 1,
            radiusB: 3,
            axis: [0, 0, 1],
            distance: 10
        )

        let below = params.cameraPosition(angle: 0, t: -1)
        let above = params.cameraPosition(angle: 0, t: 2)

        #expect(abs(below.z) < 1e-6)
        #expect(abs(abs(below.x) - 1) < 1e-6)

        #expect(abs(above.z - 10) < 1e-6)
        #expect(abs(length(above.xy) - 3) < 1e-6)
    }

    @Test
    func cameraPositionHandlesDegenerateAxis() {
        let params = CameraConeParameters(
            centerA: [0, 0, 0],
            centerB: [0, 0, 0],
            radiusA: 1,
            radiusB: 1
        )

        let position = params.cameraPosition(angle: .pi / 2, t: 0.5)
        #expect(abs(length(position) - 1) < 1e-6)
    }

    @Test
    func cameraMatrixMatchesLookAt() {
        let params = CameraConeParameters(
            centerA: [1, 2, 3],
            radiusA: 2,
            radiusB: 3,
            axis: [0, 1, 0],
            distance: 4
        )

        let angle: Float = .pi / 3
        let t: Float = 0.25
        let cameraMatrix = params.cameraMatrix(angle: angle, t: t, up: [0, 0, 1])

        let position = params.cameraPosition(angle: angle, t: t)
        let eyePosition = params.eyePosition(angle: angle, t: t)
        let expected = LookAt(position: position, target: eyePosition, up: [0, 0, 1]).cameraMatrix

        #expect(cameraMatrix.isApproximatelyEqual(to: expected, absoluteTolerance: 1e-6))
    }

    @Test
    func cameraTransformReflectsSlopeAndRotation() {
        let params = CameraConeParameters(
            centerA: [0, 0, 0],
            radiusA: 1,
            radiusB: 2,
            axis: [0, 1, 0],
            distance: 5
        )
        let rotation = Angle(degrees: 30)
        let height: Float = 0.6
        let cone = CameraCone(parameters: params, rotation: rotation, height: height)

        let expected = params.cameraMatrix(angle: Float(rotation.radians), t: height)
        #expect(cone.cameraTransform.isApproximatelyEqual(to: expected, absoluteTolerance: 1e-6))
    }

    @Test
    func parametersCodableRoundTrip() throws {
        let params = CameraConeParameters(
            centerA: [1, -2, 3],
            radiusA: 0.5,
            radiusB: 1.75,
            axis: [0, 0, -1],
            distance: 12
        )

        let data = try JSONEncoder().encode(params)
        let decoded = try JSONDecoder().decode(CameraConeParameters.self, from: data)

        #expect(decoded == params)
    }
}
