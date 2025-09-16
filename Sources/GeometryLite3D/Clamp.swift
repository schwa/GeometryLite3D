@available(*, deprecated, message: "Use FloatingPoint.clamped(to:) instead")
public func clamp<T>(_ value: T, to range: ClosedRange<T>) -> T where T: Comparable {
    min(max(value, range.lowerBound), range.upperBound)
}

public extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
