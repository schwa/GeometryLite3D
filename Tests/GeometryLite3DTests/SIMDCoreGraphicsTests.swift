import Testing
import CoreGraphics
import simd
@testable import GeometryLite3D

struct SIMDCoreGraphicsTests {
    @Test
    func simd2FromCGPointCopiesCoordinates() {
        let point = CGPoint(x: 4.5, y: -3.25)
        let vector = SIMD2<Float>(point)
        #expect(vector.x == Float(point.x))
        #expect(vector.y == Float(point.y))
    }

    @Test
    func simd2FromCGSizeCopiesDimensions() {
        let size = CGSize(width: 12.0, height: 8.0)
        let vector = SIMD2<Float>(size)
        #expect(vector.x == Float(size.width))
        #expect(vector.y == Float(size.height))
    }
}
