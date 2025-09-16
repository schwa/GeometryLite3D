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

public struct OldPerspectiveProjection: ProjectionProtocol {
    public var verticalAngleOfView: AngleF
    public var zClip: ClosedRange<Float>

    public init(verticalAngleOfView: AngleF = .degrees(90), zClip: ClosedRange<Float> = 0.01 ... 1_000) {
        self.verticalAngleOfView = verticalAngleOfView
        self.zClip = zClip
    }

    public func projectionMatrix(aspectRatio: Float) -> simd_float4x4 {
        .perspective(aspectRatio: aspectRatio, fovy: Float(verticalAngleOfView.radians), near: zClip.lowerBound, far: zClip.upperBound)
    }

    public func horizontalAngleOfView(aspectRatio: Float) -> AngleF {
        let fovy = verticalAngleOfView.radians
        let fovx = 2 * atan(tan(fovy / 2) * aspectRatio)
        return AngleF(radians: fovx)
    }
}

public typealias PerspectiveProjection = OldPerspectiveProjection

// MARK: -

public struct NewPerspectiveProjection: ProjectionProtocol {
    public var verticalAngleOfView: AngleF
    public var zClip: ClosedRange<Float>
    public var reverseZ: Bool

    // TODO: Make reverseZ optional and default to false later.
    public init(verticalAngleOfView: AngleF = .degrees(90), zClip: ClosedRange<Float> = 0.01 ... .infinity, reverseZ: Bool) {
        self.verticalAngleOfView = verticalAngleOfView
        self.zClip = zClip
        self.reverseZ = reverseZ
    }

    public func projectionMatrix(aspectRatio: Float) -> simd_float4x4 {
        return matrix_float4x4(perspectiveWithFovy: verticalAngleOfView.radians, aspect: aspectRatio, nearZ: zClip.lowerBound, farZ: zClip.upperBound, reverseZ: reverseZ)
    }
}

public extension NewPerspectiveProjection {
    init(fovy: Float, nearZ: Float, farZ: Float, reverseZ: Bool) {
        self.init(verticalAngleOfView: .radians(fovy), zClip: nearZ...farZ, reverseZ: reverseZ)
    }
}

// MARK: -

public extension float4x4 {
    // TODO: NEW
    init(perspectiveWithFovy fovy: Float, aspect: Float, nearZ: Float, farZ: Float, reverseZ: Bool) {
        let f = 1.0 / tan(fovy * 0.5)

        if reverseZ {
            // Reverse-Z with infinite far plane projection matrix
            // Maps: near plane to 1.0, infinity to 0.0
            assert(farZ == 0 || farZ.isInfinite, "reverseZ projection uses infinite far plane - farZ should be 0 or infinity, not \(farZ)")
            self.init(
                SIMD4<Float>(f / aspect, 0, 0, 0),
                SIMD4<Float>(0, f, 0, 0),
                SIMD4<Float>(0, 0, 0, -1),
                SIMD4<Float>(0, 0, nearZ, 0)
            )
        } else {
            // Standard projection matrix
            let rangeInv = 1.0 / (nearZ - farZ)
            self.init(
                SIMD4<Float>(f / aspect, 0, 0, 0),
                SIMD4<Float>(0, f, 0, 0),
                SIMD4<Float>(0, 0, (farZ + nearZ) * rangeInv, -1),
                SIMD4<Float>(0, 0, 2.0 * farZ * nearZ * rangeInv, 0)
            )
        }
    }

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

