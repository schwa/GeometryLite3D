import simd
import CoreGraphics

public extension SIMD2<Float> {
    init(_ point: CGPoint) {
        self.init(Float(point.x), Float(point.y))
    }
    init(_ size: CGSize) {
        self.init(Float(size.width), Float(size.height))
    }
}
