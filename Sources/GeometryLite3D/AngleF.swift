public struct AngleF: Equatable, Sendable {
    public var radians: Float

    @inlinable
    public static func radians(_ radians: Float) -> Self {
        .init(radians: radians)
    }

    @inlinable
    public init(radians: Float) {
        self.radians = radians
    }
}

public extension AngleF {
    static let zero: AngleF = .init(radians: 0)
}

public extension AngleF {
    @inlinable
    var degrees: Float {
        get {
            radians * 180 / .pi
        }
        set {
            radians = newValue * .pi / 180
        }
    }

    @inlinable
    static func degrees(_ degrees: Float) -> AngleF {
        .init(degrees: degrees)
    }

    @inlinable
    init(degrees: Float) {
        self.radians = degrees * .pi / 180
    }
}

public extension AngleF {
    @inlinable
    static func + (lhs: AngleF, rhs: AngleF) -> AngleF {
        .init(radians: lhs.radians + rhs.radians)
    }

    @inlinable
    static func += (lhs: inout AngleF, rhs: AngleF) {
        lhs.radians += rhs.radians
    }

    @inlinable
    static func - (lhs: AngleF, rhs: AngleF) -> AngleF {
        .init(radians: lhs.radians - rhs.radians)
    }

    @inlinable
    static func -= (lhs: inout AngleF, rhs: AngleF) {
        lhs.radians -= rhs.radians
    }

    @inlinable
    static func * (lhs: AngleF, rhs: AngleF) -> AngleF {
        .init(radians: lhs.radians * rhs.radians)
    }

    @inlinable
    static func *= (lhs: inout AngleF, rhs: AngleF) {
        lhs.radians *= rhs.radians
    }

    @inlinable
    static func / (lhs: AngleF, rhs: AngleF) -> AngleF {
        .init(radians: lhs.radians / rhs.radians)
    }

    @inlinable
    static func /= (lhs: inout AngleF, rhs: AngleF) {
        lhs.radians /= rhs.radians
    }
}

public extension AngleF {
    @inlinable
    static func + (lhs: AngleF, rhs: Float) -> AngleF {
        .init(radians: lhs.radians + rhs)
    }

    @inlinable
    static func += (lhs: inout AngleF, rhs: Float) {
        lhs.radians += rhs
    }

    @inlinable
    static func - (lhs: AngleF, rhs: Float) -> AngleF {
        .init(radians: lhs.radians - rhs)
    }

    @inlinable
    static func -= (lhs: inout AngleF, rhs: Float) {
        lhs.radians -= rhs
    }

    @inlinable
    static func * (lhs: AngleF, rhs: Float) -> AngleF {
        .init(radians: lhs.radians * rhs)
    }

    @inlinable
    static func *= (lhs: inout AngleF, rhs: Float) {
        lhs.radians *= rhs
    }

    @inlinable
    static func / (lhs: AngleF, rhs: Float) -> AngleF {
        .init(radians: lhs.radians / rhs)
    }

    @inlinable
    static func /= (lhs: inout AngleF, rhs: Float) {
        lhs.radians /= rhs
    }
}
