import Foundation
@testable import GeometryLite3D
import Testing

struct AngleTests {
    @Test
    func initialization() {
        let angle1 = AngleF(radians: .pi)
        #expect(angle1.radians == .pi)

        let angle2 = AngleF(degrees: 180)
        #expect(angle2.degrees == 180)
        #expect(abs(angle2.radians - .pi) < 1e-6)
    }

    @Test
    func conversions() {
        let angle = AngleF(degrees: 90)
        #expect(abs(angle.radians - .pi / 2) < 1e-6)

        let angle2 = AngleF(radians: .pi)
        #expect(abs(angle2.degrees - 180) < 1e-6)
    }

    @Test
    func arithmeticWithAngle() {
        let a1 = AngleF(degrees: 45)
        let a2 = AngleF(degrees: 30)

        let sum = a1 + a2
        #expect(abs(sum.degrees - 75) < 1e-6)

        let diff = a1 - a2
        #expect(abs(diff.degrees - 15) < 1e-6)
    }

    @Test
    func arithmeticWithFloat() {
        let a1 = AngleF(degrees: 45)

        let scaled = a1 * 2
        #expect(abs(scaled.degrees - 90) < 1e-6)

        let divided = a1 / 2
        #expect(abs(divided.degrees - 22.5) < 1e-6)
    }

    @Test
    func equality() {
        let a1 = AngleF(degrees: 45)
        let a2 = AngleF(degrees: 45)
        let a3 = AngleF(degrees: 90)

        #expect(a1 == a2)
        #expect(a1 != a3)
    }

    @Test
    func zeroConstant() {
        #expect(AngleF.zero.radians == 0)
        #expect(AngleF.zero.degrees == 0)
    }
}
