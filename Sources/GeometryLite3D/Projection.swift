import CoreGraphics
import simd

public protocol ProjectionProtocol: Equatable, Sendable {
    func projectionMatrix(aspectRatio: Float) -> simd_float4x4
}

public extension ProjectionProtocol {
    func projectionMatrix(for viewSize: SIMD2<Float>) -> simd_float4x4 {
        let aspectRatio = viewSize.x / viewSize.y
        return self.projectionMatrix(aspectRatio: aspectRatio)
    }

    func projectionMatrix(for viewSize: CGSize) -> simd_float4x4 {
        projectionMatrix(for: .init(viewSize))
    }

    func projectionMatrix(width: Float, height: Float) -> simd_float4x4 {
        projectionMatrix(for: [width, height])
    }
}

// MARK: -

// MARK: -

public struct PerspectiveProjection: ProjectionProtocol {
    public var verticalAngleOfView: AngleF
    public var zClip: ClosedRange<Float>
    public var reverseZ: Bool

    // TODO: Make reverseZ optional and default to false later.
    public init(verticalAngleOfView: AngleF = .degrees(90), zClip: ClosedRange<Float> = 0.01 ... .infinity, reverseZ: Bool = false) {
        self.verticalAngleOfView = verticalAngleOfView
        self.zClip = zClip
        self.reverseZ = reverseZ
    }

    public func projectionMatrix(aspectRatio: Float) -> float4x4 {
        let fovy = verticalAngleOfView.radians
        let nearZ = zClip.lowerBound
        let farZ = zClip.upperBound
        let aspect = aspectRatio

        let f = 1.0 / tan(fovy * 0.5)

        if reverseZ {
            // Reverse-Z with infinite far plane projection matrix
            // Maps: near plane to 1.0, infinity to 0.0
            return float4x4(
                SIMD4<Float>(f / aspect, 0, 0, 0),
                SIMD4<Float>(0, f, 0, 0),
                SIMD4<Float>(0, 0, 0, -1),
                SIMD4<Float>(0, 0, nearZ, 0)
            )
        } else {
            // Standard projection matrix
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

        return simd_float4x4([P, Q, R, S])
    }
}

