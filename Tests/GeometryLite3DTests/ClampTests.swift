import Testing
@testable import GeometryLite3D

struct ClampTests {
    @Test
    func clampIntegerInRange() {
        let result = clamp(5, to: 0...10)
        #expect(result == 5)
    }

    @Test
    func clampIntegerBelowRange() {
        let result = clamp(-5, to: 0...10)
        #expect(result == 0)
    }

    @Test
    func clampIntegerAboveRange() {
        let result = clamp(15, to: 0...10)
        #expect(result == 10)
    }

    @Test
    func clampFloatInRange() {
        let result = clamp(5.5, to: 0.0...10.0)
        #expect(result == 5.5)
    }

    @Test
    func clampFloatBelowRange() {
        let result = clamp(-2.5, to: 0.0...10.0)
        #expect(result == 0.0)
    }

    @Test
    func clampFloatAboveRange() {
        let result = clamp(12.5, to: 0.0...10.0)
        #expect(result == 10.0)
    }

    @Test
    func clampFloatAtBounds() {
        let lower = clamp(0.0, to: 0.0...10.0)
        #expect(lower == 0.0)

        let upper = clamp(10.0, to: 0.0...10.0)
        #expect(upper == 10.0)
    }

    @Test
    func clampedExtensionInRange() {
        let value: Float = 5.5
        let result = value.clamped(to: 0.0...10.0)
        #expect(result == 5.5)
    }

    @Test
    func clampedExtensionBelowRange() {
        let value: Float = -2.5
        let result = value.clamped(to: 0.0...10.0)
        #expect(result == 0.0)
    }

    @Test
    func clampedExtensionAboveRange() {
        let value: Float = 12.5
        let result = value.clamped(to: 0.0...10.0)
        #expect(result == 10.0)
    }

    @Test
    func clampNegativeRange() {
        let result = clamp(-5, to: -10...(-1))
        #expect(result == -5)

        let below = clamp(-15, to: -10...(-1))
        #expect(below == -10)

        let above = clamp(0, to: -10...(-1))
        #expect(above == -1)
    }

    @Test
    func clampSingleValueRange() {
        let result = clamp(100, to: 5...5)
        #expect(result == 5)

        let result2 = clamp(-100, to: 5...5)
        #expect(result2 == 5)

        let result3 = clamp(5, to: 5...5)
        #expect(result3 == 5)
    }
}