import Testing
@testable import GeometryLite3D

struct WrapTests {
    @Test
    func wrappedInRange() {
        let value: Float = 5.0
        let result = value.wrapped(to: 0...10)
        #expect(result == 5.0)
    }

    @Test
    func wrappedAboveRange() {
        let value: Float = 15.0
        let result = value.wrapped(to: 0...10)
        #expect(abs(result - 5.0) < 1e-6)
    }

    @Test
    func wrappedBelowRange() {
        let value: Float = -5.0
        let result = value.wrapped(to: 0...10)
        #expect(abs(result - 5.0) < 1e-6)
    }

    @Test
    func wrappedMultipleAbove() {
        let value: Float = 25.0
        let result = value.wrapped(to: 0...10)
        #expect(abs(result - 5.0) < 1e-6)
    }

    @Test
    func wrappedMultipleBelow() {
        let value: Float = -25.0
        let result = value.wrapped(to: 0...10)
        #expect(abs(result - 5.0) < 1e-6)
    }

    @Test
    func wrappedAtBounds() {
        let lower: Float = 0.0
        let lowerResult = lower.wrapped(to: 0...10)
        #expect(lowerResult == 0.0)

        let upper: Float = 10.0
        let upperResult = upper.wrapped(to: 0...10)
        #expect(upperResult == 0.0)
    }

    @Test
    func wrappedNegativeRange() {
        let value: Float = 5.0
        let result = value.wrapped(to: -10...(-5))
        #expect(abs(result - (-10.0)) < 1e-6)
    }

    @Test
    func wrappedSmallRange() {
        let value: Float = 3.5
        let result = value.wrapped(to: 0...1)
        #expect(abs(result - 0.5) < 1e-6)
    }

    @Test
    func wrappedAngles() {
        let angle: Float = 370.0
        let result = angle.wrapped(to: 0...360)
        #expect(abs(result - 10.0) < 1e-6)

        let negativeAngle: Float = -30.0
        let negResult = negativeAngle.wrapped(to: 0...360)
        #expect(abs(negResult - 330.0) < 1e-6)
    }

    @Test
    func wrappedDouble() {
        let value: Double = 15.0
        let result = value.wrapped(to: 0...10)
        #expect(abs(result - 5.0) < 1e-10)
    }
}