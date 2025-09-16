import Testing
import simd
import SwiftUI
@testable import GeometryLite3D

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
}