import CoreGraphics
import simd

public protocol ProjectionProtocol: Equatable, Sendable {
    func projectionMatrix(aspectRatio: Float) -> float4x4
    /// True when the near plane maps to depth 1.
    var isReversedDepth: Bool { get }
}

public extension ProjectionProtocol {
    @inlinable
    func projectionMatrix(for viewSize: SIMD2<Float>) -> float4x4 {
        let aspectRatio = viewSize.x / viewSize.y
        return self.projectionMatrix(aspectRatio: aspectRatio)
    }

    @inlinable
    func projectionMatrix(for viewSize: CGSize) -> float4x4 {
        projectionMatrix(for: .init(viewSize))
    }

    @inlinable
    func projectionMatrix(width: Float, height: Float) -> float4x4 {
        projectionMatrix(for: [width, height])
    }
}

// MARK: -

public struct PerspectiveProjection: ProjectionProtocol {
    public enum DepthMode: Equatable, Sendable {
        /// Depth 0...1, with near at 0 and far at 1.
        case standard(zClip: ClosedRange<Float>)
        /// Reversed depth with no far plane. The near plane maps to 1. Use a `.greater` depth test and clear depth to 0.
        case reversedInfinite(zNear: Float)
        /// Reversed depth with a far plane. Near maps to 1 and far maps to 0. Use a `.greater` depth test and clear depth to 0.
        case reversed(zClip: ClosedRange<Float>)
    }

    public var verticalAngleOfView: AngleF
    public var depthMode: DepthMode

    @inlinable
    public init(verticalAngleOfView: AngleF = .degrees(90), depthMode: DepthMode = .standard(zClip: 0.01 ... 100)) {
        self.verticalAngleOfView = verticalAngleOfView
        self.depthMode = depthMode
    }

    @inlinable
    public var isReversedDepth: Bool {
        switch depthMode {
        case .standard:
            false

        case .reversed, .reversedInfinite:
            true
        }
    }

    @inlinable
    public func projectionMatrix(aspectRatio: Float) -> float4x4 {
        let fovy = verticalAngleOfView.radians
        let aspect = aspectRatio
        let f = 1.0 / tan(fovy * 0.5)

        switch depthMode {
        case .reversedInfinite(let zNear):
            return float4x4(
                SIMD4<Float>(f / aspect, 0, 0, 0),
                SIMD4<Float>(0, f, 0, 0),
                SIMD4<Float>(0, 0, 0, -1),
                SIMD4<Float>(0, 0, zNear, 0)
            )

        case .reversed(let zClip):
            let nearZ = zClip.lowerBound
            let farZ = zClip.upperBound
            let rangeInv = 1.0 / (farZ - nearZ)
            return float4x4(
                SIMD4<Float>(f / aspect, 0, 0, 0),
                SIMD4<Float>(0, f, 0, 0),
                SIMD4<Float>(0, 0, nearZ * rangeInv, -1),
                SIMD4<Float>(0, 0, farZ * nearZ * rangeInv, 0)
            )

        case .standard(let zClip):
            let nearZ = zClip.lowerBound
            let farZ = zClip.upperBound
            let rangeInv = 1.0 / (nearZ - farZ)
            return float4x4(
                SIMD4<Float>(f / aspect, 0, 0, 0),
                SIMD4<Float>(0, f, 0, 0),
                SIMD4<Float>(0, 0, farZ * rangeInv, -1),
                SIMD4<Float>(0, 0, farZ * nearZ * rangeInv, 0)
            )
        }
    }
}

// MARK: -

public struct OrthographicProjection: ProjectionProtocol {
    public enum DepthMode: Equatable, Sendable {
        /// Depth 0...1, with near at 0 and far at 1.
        case standard(zClip: ClosedRange<Float>)
        /// Reversed depth. Near maps to 1 and far maps to 0. Use a `.greater` depth test and clear depth to 0.
        case reversed(zClip: ClosedRange<Float>)
    }

    public var halfHeight: Float
    public var depthMode: DepthMode

    @inlinable
    public init(halfHeight: Float = 1, depthMode: DepthMode = .standard(zClip: 0.01 ... 100)) {
        self.halfHeight = halfHeight
        self.depthMode = depthMode
    }

    @inlinable
    public var isReversedDepth: Bool {
        switch depthMode {
        case .standard:
            false

        case .reversed:
            true
        }
    }

    @inlinable
    public func projectionMatrix(aspectRatio: Float) -> float4x4 {
        let xScale = 1 / (halfHeight * aspectRatio)
        let yScale = 1 / halfHeight

        switch depthMode {
        case .standard(let zClip):
            let near = zClip.lowerBound
            let far = zClip.upperBound
            let rangeInv = 1 / (far - near)
            return float4x4(
                SIMD4<Float>(xScale, 0, 0, 0),
                SIMD4<Float>(0, yScale, 0, 0),
                SIMD4<Float>(0, 0, -rangeInv, 0),
                SIMD4<Float>(0, 0, -near * rangeInv, 1)
            )

        case .reversed(let zClip):
            let near = zClip.lowerBound
            let far = zClip.upperBound
            let rangeInv = 1 / (far - near)
            return float4x4(
                SIMD4<Float>(xScale, 0, 0, 0),
                SIMD4<Float>(0, yScale, 0, 0),
                SIMD4<Float>(0, 0, rangeInv, 0),
                SIMD4<Float>(0, 0, far * rangeInv, 1)
            )
        }
    }
}

// MARK: -

public extension float4x4 {
    /// Changes clip z to w - z. This swaps standard and reversed depth.
    static let reversedDepth = float4x4(
        SIMD4<Float>(1, 0, 0, 0),
        SIMD4<Float>(0, 1, 0, 0),
        SIMD4<Float>(0, 0, -1, 0),
        SIMD4<Float>(0, 0, 1, 1)
    )

    /// View matrix for a camera at `eye` that looks along `forward`. If `forward` is parallel to `up`, a different up vector is used.
    @inlinable
    static func viewMatrix(eye: SIMD3<Float>, forward: SIMD3<Float>, up: SIMD3<Float> = [0, 1, 0]) -> float4x4 {
        LookAt(position: eye, target: eye + normalize(forward), up: up).viewMatrix
    }
}
