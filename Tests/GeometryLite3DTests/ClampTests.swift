@testable import GeometryLite3D
import Testing

struct ClampTests {
    @Test
    func clampedMethodKeepsValueWhenInsideRange() {
        let value: Float = 5
        let clamped = value.clamped(to: 1...10)
        #expect(clamped == 5)
    }

    @Test
    func clampedMethodClampsOutOfRange() {
        let value: Float = -2
        let clamped = value.clamped(to: 0...1)
        #expect(clamped == 0)
    }
}
