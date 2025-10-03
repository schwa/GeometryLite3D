import simd

public struct Skew: Sendable, Equatable {
    public var xy: Float
    public var xz: Float
    public var yz: Float

    public init(xy: Float, xz: Float, yz: Float) {
        self.xy = xy
        self.xz = xz
        self.yz = yz
    }

    public static let zero = Self(xy: 0, xz: 0, yz: 0)
}
