import simd

/// A camera's view matrix, projection, and viewport. View points have the origin at the top-left with y down. Depth is the clip z / w value in 0...1.
public struct ViewProjection: Equatable, Sendable {
    public var viewMatrix: float4x4
    public var projectionMatrix: float4x4
    public var isReverseZ: Bool
    public var viewSize: SIMD2<Float>

    @available(*, deprecated, renamed: "isReverseZ")
    public var isReversedDepth: Bool {
        get { isReverseZ }
        set { isReverseZ = newValue }
    }

    @inlinable
    public init(viewMatrix: float4x4, projectionMatrix: float4x4, isReverseZ: Bool, viewSize: SIMD2<Float>) {
        self.viewMatrix = viewMatrix
        self.projectionMatrix = projectionMatrix
        self.isReverseZ = isReverseZ
        self.viewSize = viewSize
    }

    @available(*, deprecated, renamed: "init(viewMatrix:projectionMatrix:isReverseZ:viewSize:)")
    @inlinable
    public init(viewMatrix: float4x4, projectionMatrix: float4x4, isReversedDepth: Bool, viewSize: SIMD2<Float>) {
        self.init(viewMatrix: viewMatrix, projectionMatrix: projectionMatrix, isReverseZ: isReversedDepth, viewSize: viewSize)
    }

    @inlinable
    public init(viewMatrix: float4x4, projection: some ProjectionProtocol, viewSize: SIMD2<Float>) {
        self.init(
            viewMatrix: viewMatrix,
            projectionMatrix: projection.projectionMatrix(for: viewSize),
            isReverseZ: projection.isReverseZ,
            viewSize: viewSize
        )
    }

    @inlinable
    public var matrix: float4x4 {
        projectionMatrix * viewMatrix
    }

    @inlinable
    public var nearDepth: Float {
        isReverseZ ? 1 : 0
    }

    @inlinable
    public var frustum: Frustum {
        Frustum(viewProjection: matrix)
    }

    /// Returns (view x, view y, depth), or nil if the point is at or behind the camera plane.
    @inlinable
    public func project(_ worldPoint: SIMD3<Float>) -> SIMD3<Float>? {
        let clip = matrix * SIMD4<Float>(worldPoint, 1)
        guard clip.w > 0 else {
            return nil
        }
        let normalized = clip.xyz / clip.w
        return SIMD3<Float>(viewPoint(clipPoint: normalized.xy), normalized.z)
    }

    /// Inverse of `project`.
    @inlinable
    public func unproject(_ viewPoint: SIMD3<Float>) -> SIMD3<Float> {
        let xy = clipPoint(viewPoint: viewPoint.xy)
        let clip = SIMD4<Float>(xy.x, xy.y, viewPoint.z, 1)
        let world = matrix.inverse * clip
        return world.xyz / world.w
    }

    /// Ray from the near plane through a view point.
    @inlinable
    public func ray(through viewPoint: SIMD2<Float>) -> Ray3D {
        Ray3D(clipPoint: clipPoint(viewPoint: viewPoint), viewMatrix: viewMatrix, projectionMatrix: projectionMatrix, reverseZ: isReverseZ)
    }

    @inlinable
    public func clipPoint(viewPoint: SIMD2<Float>) -> SIMD2<Float> {
        SIMD2<Float>(viewPoint.x / viewSize.x * 2 - 1, 1 - viewPoint.y / viewSize.y * 2)
    }

    @inlinable
    public func viewPoint(clipPoint: SIMD2<Float>) -> SIMD2<Float> {
        SIMD2<Float>((clipPoint.x + 1) * 0.5 * viewSize.x, (1 - clipPoint.y) * 0.5 * viewSize.y)
    }
}
