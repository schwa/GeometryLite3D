import Testing
@testable import GeometryLite3D

struct AngleFTests {
    @Test
    func degreesInitializerProducesExpectedRadians() {
        let angle = AngleF.degrees(90)
        #expect(abs(angle.radians - .pi / 2) < 1e-6)
    }

    @Test
    func degreesPropertyRoundTrips() {
        var angle = AngleF(radians: .pi / 3)
        #expect(abs(angle.degrees - 60) < 1e-6)

        angle.degrees = 180
        #expect(abs(angle.radians - .pi) < 1e-6)
    }

    @Test
    func arithmeticWithAngles() {
        let a = AngleF.degrees(15)
        let b = AngleF.degrees(30)
        let sum = a + b
        #expect(abs(sum.degrees - 45) < 1e-5)

        var difference = sum
        difference -= a
        #expect(abs(difference.degrees - 30) < 1e-5)
    }

    @Test
    func arithmeticWithScalars() {
        let angle = AngleF.degrees(60)
        let scaled = angle * 2
        #expect(abs(scaled.degrees - 120) < 1e-5)

        let reduced = scaled / 4
        #expect(abs(reduced.degrees - 30) < 1e-5)
    }

    @Test
    func radiansFactoryCreatesAngle() {
        let angle = AngleF.radians(.pi / 6)
        #expect(abs(angle.degrees - 30) < 1e-6)
    }

    @Test
    func zeroConstantIsZeroRadians() {
        #expect(AngleF.zero.radians == 0)
    }

    @Test
    func mutatingOperatorsWithAngles() {
        var angle = AngleF.degrees(45)
        angle += AngleF.degrees(15)
        #expect(abs(angle.degrees - 60) < 1e-5)

        angle -= AngleF.degrees(30)
        #expect(abs(angle.degrees - 30) < 1e-5)

        angle *= AngleF.degrees(2)
        #expect(abs(angle.radians - (AngleF.degrees(30).radians * AngleF.degrees(2).radians)) < 1e-6)

        angle /= AngleF.degrees(15)
        #expect(abs(angle.radians - (AngleF.degrees(30).radians * AngleF.degrees(2).radians / AngleF.degrees(15).radians)) < 1e-6)
    }

    @Test
    func mutatingOperatorsWithScalarsUseRadians() {
        var angle = AngleF.degrees(90)
        angle += .pi / 6
        #expect(abs(angle.radians - (.pi / 2 + .pi / 6)) < 1e-6)

        angle -= .pi / 3
        #expect(abs(angle.radians - (.pi / 2 - .pi / 6)) < 1e-6)

        angle *= 0.5
        #expect(abs(angle.radians - ((.pi / 2 - .pi / 6) * 0.5)) < 1e-6)

        angle /= 0.25
        #expect(abs(angle.radians - ((.pi / 2 - .pi / 6) * 0.5 / 0.25)) < 1e-6)
    }
}
