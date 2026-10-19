import CoreGraphics
import simd

public extension SIMD2<Float> {
    @inlinable
    init(_ point: CGPoint) {
        self.init(Float(point.x), Float(point.y))
    }
    @inlinable
    init(_ size: CGSize) {
        self.init(Float(size.width), Float(size.height))
    }
}
