import CoreGraphics
import simd

public protocol ProjectionProtocol: Equatable, Sendable {
    func projectionMatrix(aspectRatio: Float) -> float4x4
}

public extension ProjectionProtocol {
    func projectionMatrix(for viewSize: SIMD2<Float>) -> float4x4 {
        let aspectRatio = viewSize.x / viewSize.y
        return self.projectionMatrix(aspectRatio: aspectRatio)
    }

    func projectionMatrix(for viewSize: CGSize) -> float4x4 {
        projectionMatrix(for: .init(viewSize))
    }

    func projectionMatrix(width: Float, height: Float) -> float4x4 {
        projectionMatrix(for: [width, height])
    }
}

// MARK: -

// MARK: -

public struct PerspectiveProjection: ProjectionProtocol {
    public enum DepthMode: Equatable, Sendable {
        case standard(zClip: ClosedRange<Float>)
        case reversed(zMin: Float)
    }

    public var verticalAngleOfView: AngleF
    public var depthMode: DepthMode

    public init(verticalAngleOfView: AngleF = .degrees(90), depthMode: DepthMode = .standard(zClip: 0.01 ... 100)) {
        self.verticalAngleOfView = verticalAngleOfView
        self.depthMode = depthMode
    }

    public func projectionMatrix(aspectRatio: Float) -> float4x4 {
        let fovy = verticalAngleOfView.radians
        let aspect = aspectRatio
        let f = 1.0 / tan(fovy * 0.5)

        switch depthMode {
        case .reversed(let zMin):
            return float4x4(
                SIMD4<Float>(f / aspect, 0, 0, 0),
                SIMD4<Float>(0, f, 0, 0),
                SIMD4<Float>(0, 0, 0, -1),
                SIMD4<Float>(0, 0, zMin, 0)
            )
        case .standard(let zClip):
            let nearZ = zClip.lowerBound
            let farZ = zClip.upperBound
            let rangeInv = 1.0 / (nearZ - farZ)
            return float4x4(
                SIMD4<Float>(f / aspect, 0, 0, 0),
                SIMD4<Float>(0, f, 0, 0),
                SIMD4<Float>(0, 0, (farZ + nearZ) * rangeInv, -1),
                SIMD4<Float>(0, 0, 2.0 * farZ * nearZ * rangeInv, 0)
            )
        }
    }
}

// MARK: -

public extension float4x4 {
    // TODO: OLD
    static func perspective(aspectRatio: Float, fovy: Float, near: Float, far: Float) -> Self {
        let yScale = 1 / tan(fovy * 0.5)
        let xScale = yScale / aspectRatio
        let zRange = far - near
        let zScale = -(far + near) / zRange
        let wzScale = -2 * far * near / zRange

        let P: SIMD4<Float> = [xScale, 0, 0, 0]
        let Q: SIMD4<Float> = [0, yScale, 0, 0]
        let R: SIMD4<Float> = [0, 0, zScale, -1]
        let S: SIMD4<Float> = [0, 0, wzScale, 0]

        return float4x4([P, Q, R, S])
    }
}
