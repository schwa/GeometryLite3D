# ISSUES.md

---

## 1: OrthographicProjection

+++
status: closed
priority: medium
kind: feature
labels: effort:m
created: 2026-10-15T13:26:32Z
updated: 2026-10-15T13:38:52Z
closed: 2026-10-15T13:38:52Z
+++

A ProjectionProtocol type for orthographic cameras, alongside PerspectiveProjection: a vertical size (or half-height), near/far, and the same DepthMode choices (standard zClip, reversed). MetalSprocketsSceneGraph needs it for orthographic camera nodes (its #87) and to load orthographic cameras from glTF and Model I/O. Filed from MetalSprocketsSceneGraph #97.

- `2026-10-15T13:32:17Z`: Also wanted by MetalSprocketsPBR (PBRCamera.swift orthographic, reversed depth).
- `2026-10-15T13:33:49Z`: Related: #6 (reversed-depth orthographic matrix helpers).

---

## 2: float4x4 normalMatrix

+++
status: closed
priority: medium
kind: enhancement
labels: effort:xs
created: 2026-10-15T13:26:32Z
updated: 2026-10-15T13:37:51Z
closed: 2026-10-15T13:37:51Z
+++

Add `var translation: SIMD3<Float>` (get/set, columns.3.xyz), `var upperLeft3x3: simd_float3x3`, and a `normalMatrix` (inverse transpose of the upper 3x3). MetalSprocketsSceneGraph spells `SIMD3(m.columns.3.x, m.columns.3.y, m.columns.3.z)` in many places and has its own normal matrix helper. Filed from MetalSprocketsSceneGraph #97.

- `2026-10-15T13:34:05Z`: translation (get/set) and upperLeft3x3 already exist in SIMD+Matrix+Extensions.swift. Remaining: normalMatrix (inverse transpose of upperLeft3x3).

---

## 3: BoundingBox helpers: union, center, size, contains

+++
status: closed
priority: low
kind: enhancement
labels: effort:s
created: 2026-10-15T13:26:32Z
updated: 2026-10-15T13:40:59Z
closed: 2026-10-15T13:40:59Z
+++

MetalSprocketsSceneGraph has its own BoundingBox.union and computes centers and sizes inline. Add `union(_:)`, `center`, `size`, `contains(_ point:)`, and an init from a sequence of points. Filed from MetalSprocketsSceneGraph #97.

- `2026-10-15T13:35:53Z`: Related: #10 (rename to BoundingBox3D).

---

## 4: Ray and ray intersection tests

+++
status: closed
priority: medium
kind: feature
labels: effort:m
created: 2026-10-15T13:26:32Z
updated: 2026-10-15T13:40:12Z
closed: 2026-10-15T13:40:12Z
+++

A `Ray` (origin, normalized direction, init from a view point and view/projection matrices for Metal clip space, standard or reversed depth) plus ray/triangle (Möller–Trumbore, returning t and barycentrics, optional back-face culling) and ray/box (slab test returning entry t and face normal). Currently private in MetalSprocketsSceneGraph's HitTest.swift. Filed from MetalSprocketsSceneGraph #97.

---

## 5: Frustum test for bounding boxes

+++
status: closed
priority: low
kind: feature
labels: effort:s
created: 2026-10-15T13:26:32Z
updated: 2026-10-15T13:41:20Z
closed: 2026-10-15T13:41:20Z
+++

A conservative box-in-frustum test for a view-projection matrix in Metal clip space (z in 0...w), as in MetalSprocketsSceneGraph's Culling.swift isInFrustum. Optionally a Frustum type with the six planes. Filed from MetalSprocketsSceneGraph #97.

- `2026-10-15T13:41:19Z`: Frustum assumes Metal clip z (0...w): works with reversed/reversedFinite perspective and OrthographicProjection. The .standard modes use OpenGL z (-w...w), so the near plane is too tight there.

---

## 6: Projection and view matrix helpers

+++
status: closed
priority: medium
kind: enhancement
labels: effort:m
created: 2026-10-15T13:26:33Z
updated: 2026-10-15T13:39:31Z
closed: 2026-10-15T13:39:31Z
+++

Matrix builders MetalSprocketsSceneGraph keeps privately in Shadows.swift and SceneGraphRenderer.swift: viewMatrix(eye:forward:) (with an up fallback), perspective(fieldOfView:near:far:) and orthographic(halfSize:near:far:) with reversed depth, and the reversed-depth remap matrix (clip z to w - z). Ideally expressed through PerspectiveProjection/OrthographicProjection depth modes. Filed from MetalSprocketsSceneGraph #97.

- `2026-10-15T13:32:17Z`: MetalSprocketsPBR needs the same: finite near/far reversed-depth perspective (PerspectiveProjection.reversed is infinite-far only) and a reversed-depth orthographic(halfWidth:halfHeight:near:far:). See PBRCamera.swift.
- `2026-10-15T13:33:49Z`: Related: #1 (OrthographicProjection type).
- `2026-10-15T13:39:31Z`: Added PerspectiveProjection.DepthMode.reversedFinite(zClip:), float4x4.reversedDepth, float4x4.viewMatrix(eye:forward:up:). Reversed orthographic is OrthographicProjection(.reversed) from #1. Note: the new enum case breaks exhaustive switches on PerspectiveProjection.DepthMode in dependents.

---

## 7: Transform3D (translation, rotation, scale) value type

+++
status: closed
priority: medium
kind: feature
labels: effort:s
created: 2026-10-15T13:26:33Z
updated: 2026-10-15T13:38:20Z
closed: 2026-10-15T13:38:20Z
+++

A TRS struct (translation, simd_quatf rotation, scale) with `matrix` and `init(matrix:)` (via the existing decomposition, falling back to identity when not decomposable), identity, and interpolation (mix translation/scale, slerp rotation). MetalSprocketsSceneGraph's SceneGraph.TRS would become a typealias. Filed from MetalSprocketsSceneGraph #97.

- `2026-10-15T13:33:49Z`: Related: #8 (quaternion look rotation).
- `2026-10-15T13:35:06Z`: Name the type Transform3D. Related: TransformComponents (Decomposition.swift) holds decompose() output, but has no matrix/compose or interpolation, and carries perspective/skew.

---

## 8: Quaternion look rotation

+++
status: closed
priority: low
kind: feature
labels: effort:s
created: 2026-10-15T13:26:33Z
updated: 2026-10-15T13:41:48Z
closed: 2026-10-15T13:41:48Z
+++

simd_quatf that turns a local front axis towards a target from a position, keeping a world up vector up (with a fallback when looking along up). MetalSprocketsSceneGraph's look-at constraint has this privately (Constraint.swift lookRotation); LookAt only builds a camera matrix. Filed from MetalSprocketsSceneGraph #97.

- `2026-10-15T13:33:49Z`: Related: #7 (TRS type).

---

## 9: float4x4.isMirroring

+++
status: closed
priority: low
kind: enhancement
labels: effort:xs
created: 2026-10-15T13:32:17Z
updated: 2026-10-15T13:40:21Z
closed: 2026-10-15T13:40:21Z
+++

Add `var isMirroring: Bool { determinant < 0 }` on float4x4: true when the transform flips winding. MetalSprocketsPBR (PBRFrameRules.swift) and likely MetalSprocketsSceneGraph use it to pick front-face winding for mirrored instances.

---

## 10: Rename BoundingBox to BoundingBox3D

+++
status: closed
priority: low
kind: task
labels: effort:xs
created: 2026-10-15T13:35:53Z
updated: 2026-10-15T13:40:43Z
closed: 2026-10-15T13:40:43Z
+++

Rename BoundingBox to BoundingBox3D, to match the planned Transform3D naming (#7). This is a breaking API change for dependents (MetalSprocketsSceneGraph, etc.). Consider a deprecated typealias BoundingBox = BoundingBox3D. Do before or with #3 (BoundingBox helpers) to avoid churn.

---

## 11: Standard depth modes use OpenGL clip z (-1...1), not Metal (0...1)

+++
status: closed
priority: medium
kind: bug
labels: effort:s
created: 2026-10-15T13:42:15Z
updated: 2026-10-15T13:58:26Z
closed: 2026-10-15T13:58:26Z
+++

PerspectiveProjection.DepthMode.standard, OrthographicProjection.DepthMode.standard and float4x4.perspective produce OpenGL-style clip z (-w...w), matching SceneKit. The reversed modes, Frustum and Ray assume Metal clip z (0...w).

Effects:
- Frustum(viewProjection:) with a .standard matrix has a near plane that is too tight (it culls the half of the depth range where z < 0).
- Ray(clipPoint:...) with reversedDepth: false starts at clip z 0, which is inside the frustum, not on the near plane.
- Depth precision is wasted if these matrices feed Metal directly.

Decide: change .standard to Metal 0...1 (breaking; update the SceneKit ground-truth tests), or add explicit Metal standard modes and document .standard as OpenGL. Related: #1, #5, #6, #4.

---

## 12: Deprecate float4x4.perspective(aspectRatio:fovy:near:far:)

+++
status: closed
priority: low
kind: task
labels: effort:xs
created: 2026-10-15T13:46:30Z
updated: 2026-10-15T14:20:07Z
closed: 2026-10-15T13:58:47Z
+++

Projection.swift marks float4x4.perspective with '// TODO: OLD'. It gives the same matrix as PerspectiveProjection(verticalAngleOfView:depthMode: .standard(zClip:)), and also uses OpenGL clip z (see #11). Mark it @available(*, deprecated) pointing at PerspectiveProjection, then remove it in a later release. Check dependents (MetalSprocketsSceneGraph, MetalSprocketsPBR) for callers first.

- `2026-10-15T13:58:47Z`: Deprecated, not removed. Remaining callers: MetalSprocketsAddOns TransformsTests.swift:17 and MetalSprocketsExamples MeshDissolveDemoView.swift:46. Remove after those move to PerspectiveProjection.
- `2026-10-15T14:20:07Z`: Removed outright (no deprecation). Callers in MetalSprocketsAddOns TransformsTests.swift:17 and MetalSprocketsExamples MeshDissolveDemoView.swift:46 must move to PerspectiveProjection.

---

## 13: Verify builds on all declared platforms (ModelIO on watchOS?)

+++
status: closed
priority: high
kind: task
labels: effort:s
created: 2026-10-15T14:13:10Z
updated: 2026-10-15T14:14:31Z
closed: 2026-10-15T14:14:31Z
+++

Package.swift declares macOS, iOS, tvOS, watchOS and visionOS, but only macOS has been built and tested. BoundingBox3D.swift imports ModelIO for init(from: MDLAxisAlignedBoundingBox); ModelIO is likely not available on watchOS. Build every platform with xcb (--destination ios/tvos/watch/vision). If ModelIO is missing, wrap the ModelIO init in #if canImport(ModelIO).

- `2026-10-15T14:14:31Z`: Won't fix: not a concern.

---

## 14: Release 0.2.0 with notes for breaking changes

+++
status: closed
priority: high
kind: task
labels: effort:s
depends: 16
created: 2026-10-15T14:13:10Z
updated: 2026-10-15T14:14:49Z
closed: 2026-10-15T14:14:49Z
+++

Unreleased breaking changes since 0.1.1: .standard depth modes now give 0...1 clip z (#11); BoundingBox renamed to BoundingBox3D (#10, deprecated typealias kept); releativeTolerance renamed to relativeTolerance; new PerspectiveProjection.DepthMode.reversedFinite case (#6); float4x4.perspective deprecated (#12). Write release notes and update dependents (MetalSprocketsSceneGraph, MetalSprocketsPBR, MetalSprocketsAddOns, MetalSprocketsExamples). Do after the API-naming issues if they land first.

- `2026-10-15T14:14:49Z`: Won't do: not a task for this tracker.

---

## 15: Ray3D clashes with Spatial.Ray3D

+++
status: closed
priority: medium
kind: enhancement
labels: effort:xs
created: 2026-10-15T14:13:10Z
updated: 2026-10-15T14:14:31Z
closed: 2026-10-15T14:14:31Z
+++

Files that import both GeometryLite3D and Spatial must write GeometryLite3D.Ray3D. Pick a name that does not clash (for example Ray), or accept the clash. Decide before the next release.

- `2026-10-15T14:14:31Z`: Won't fix: not a concern.

---

## 16: Make depth mode and translation naming consistent

+++
status: closed
priority: medium
kind: enhancement
labels: effort:s
created: 2026-10-15T14:13:10Z
updated: 2026-10-15T14:18:48Z
closed: 2026-10-15T14:18:48Z
+++

PerspectiveProjection.DepthMode has .reversed(zMin:) next to .reversedFinite(zClip:). TransformComponents uses 'translate' while everything else uses 'translation'. Both LookAt.viewMatrix and float4x4.viewMatrix(eye:forward:up:) exist. Choose names, add deprecated aliases where needed. Decide before the next release.

---

## 17: Add Codable to Transform3D and BoundingBox3D

+++
status: closed
priority: low
kind: enhancement
labels: effort:xs
created: 2026-10-15T14:13:10Z
updated: 2026-10-15T14:19:12Z
closed: 2026-10-15T14:19:12Z
+++

Scene graphs need to save transforms and bounds. CameraConeParameters is already Codable. simd_quatf is not Codable, so Transform3D needs a custom encode/decode (store the quaternion vector).

---

## 18: Frustum: replace mutable planes array with fixed planes

+++
status: closed
priority: low
kind: enhancement
labels: effort:xs
created: 2026-10-15T14:13:10Z
updated: 2026-10-15T14:20:23Z
closed: 2026-10-15T14:20:23Z
+++

Frustum.planes is a public var [SIMD4<Float>], so callers can set a wrong count, and it allocates. Use six named stored properties (left, right, bottom, top, near, far) or a fixed-size storage.

---

## 19: Make Euler Equatable and Sendable

+++
status: closed
priority: low
kind: enhancement
labels: effort:xs
created: 2026-10-15T14:13:10Z
updated: 2026-10-15T14:20:42Z
closed: 2026-10-15T14:20:42Z
+++

Every other public value type is Equatable and Sendable. Euler is neither.

---

## 20: Packed3 Float16 conversions excluded on tvOS and visionOS

+++
status: closed
priority: low
kind: bug
labels: effort:xs
created: 2026-10-15T14:13:10Z
updated: 2026-10-15T14:15:23Z
closed: 2026-10-15T14:15:23Z
+++

The Float16 initializers use #if os(iOS) || (os(macOS) && !arch(x86_64)). Float16 is available on tvOS, watchOS and visionOS too. Use a condition based on Float16 availability (for example !(os(macOS) && arch(x86_64))).

---

## 21: Define scope relative to Apple's Spatial framework

+++
status: closed
priority: low
kind: documentation
labels: effort:s
created: 2026-10-15T14:13:10Z
updated: 2026-10-15T14:16:06Z
closed: 2026-10-15T14:16:06Z
+++

Spatial now has Rect3D, AffineTransform3D, Rotation3D, ProjectiveTransform3D and Ray3D. Write down in the README what GeometryLite3D is for (Float/SIMD convenience for Metal, orthographic projection, frustum culling, ray-triangle tests) and what callers should take from Spatial. Consider conversion helpers between the types.

- `2026-10-15T14:16:06Z`: Won't do: Spatial is Double-based (Float types need macOS 26), so it doesn't fit Metal/SIMD Float use. GeometryLite3D stays independent.

---

## 22: BoundingBox3D has no empty state, emptiness check, or radius

+++
status: closed
priority: medium
kind: enhancement
labels: effort:s
created: 2026-10-15T14:35:18Z
updated: 2026-10-15T14:37:05Z
closed: 2026-10-15T14:37:05Z
+++

BoundingBox3D has no way to represent an empty box (e.g. a starting value for union folds), no isEmpty check, and no bounding-sphere radius. Clients like MetalSprocketsPBR keep their own PBRBounds type because of this (it has .empty, isEmpty, and radius).

---

## 23: Depth convention is restated across Projection, Ray3D, and Frustum

+++
status: closed
priority: medium
kind: enhancement
labels: architecture, effort:m
created: 2026-10-15T14:40:01Z
updated: 2026-10-15T14:46:26Z
closed: 2026-10-15T14:46:26Z
+++

The depth convention (standard / reversed / reversed-infinite) is encoded separately in PerspectiveProjection.DepthMode, OrthographicProjection.DepthMode, Ray3D(clipPoint:viewMatrix:projectionMatrix:reversedDepth: Bool), and float4x4.reversedDepth. Frustum assumes clip z in 0...w. Callers must keep these in sync by hand: a .reversedInfinite projection used with Ray3D(reversedDepth: false) gives wrong picking rays with no error.

Viewport-to-clip math exists only inside Ray3D(viewPoint:). There is no project/unproject for points.

Idea: one camera / view-projection type (view matrix + projection + viewport) that owns the depth mode and provides ray picking, project/unproject, and the frustum. Boundary tests could replace part of ProjectionTests, Ray3DTests, FrustumTests, and SpatialGroundTruthTests.

---

## 24: Look-at basis construction is duplicated with inconsistent degenerate handling

+++
status: closed
priority: medium
kind: enhancement
labels: architecture, effort:s
created: 2026-10-15T14:40:02Z
updated: 2026-10-15T14:45:21Z
closed: 2026-10-15T14:45:21Z
+++

Four places build a right/up/forward frame:
- LookAt.cameraMatrix
- float4x4.viewMatrix(eye:forward:up:)
- simd_quatf.lookRotation (private orthonormalBasis)
- CameraConeParameters.cameraPosition (arbitrary perpendicular vector)

Only viewMatrix and lookRotation handle up parallel to forward. LookAt.cameraMatrix returns NaNs in that case; viewMatrix exists partly to work around it.

Idea: one shared basis helper with a single fallback rule, used by all four. Edge-case tests at that helper could replace the overlapping checks in LookAtTests, LookRotationTests, and CameraConeTests.

---

## 25: Transform3D and TransformComponents overlap; Transform3D(matrix:) silently loses data

+++
status: closed
priority: low
kind: enhancement
labels: architecture, effort:m
created: 2026-10-15T14:40:02Z
updated: 2026-10-15T14:47:59Z
closed: 2026-10-15T14:47:59Z
+++

Transform3D and TransformComponents (Decomposition.swift) both model a decomposed matrix. Transform3D(matrix:) drops skew and perspective without warning, and returns .identity when decomposition fails (instead of nil/throwing). Euler supports only .zyx and has no conversion back to a quaternion.

Idea: make the matrix <-> components conversion one boundary with explicit failure (failable init) and round-trip tests. Decide whether Transform3D should be a lossless view or document/validate the lossy case.

---

## 26: CameraCone is a thin wrapper and the only SwiftUI import

+++
status: closed
priority: low
kind: enhancement
labels: architecture, effort:xs
created: 2026-10-15T14:40:02Z
updated: 2026-10-15T14:47:07Z
closed: 2026-10-15T14:47:07Z
+++

CameraCone only stores parameters + rotation + height and forwards to CameraConeParameters.cameraMatrix. It uses SwiftUI.Angle while the rest of the library uses AngleF, so CameraCone.swift is the only file importing SwiftUI. CameraConeParameters.eyePosition(angle:t:) ignores both arguments.

Idea: merge CameraCone into CameraConeParameters (or vice versa), use AngleF, drop the SwiftUI import, and remove or fix eyePosition's unused arguments.

---

## 27: Make BoundingBox3D generic over scalar type

+++
status: new
priority: medium
kind: enhancement
labels: effort:m, architecture, deferred
created: 2026-10-15T14:46:48Z
updated: 2026-10-15T14:53:16Z
+++

BoundingBox3D is hard-wired to SIMD3<Float>. SwiftMesh is making Mesh generic over Float/Double (SwiftMesh #57) and uses BoundingBox3D for Mesh.bounds, so it needs a Double box too.

Make it BoundingBox3D<Scalar: SIMDScalar & BinaryFloatingPoint> (or similar). Keep a Float typealias or default so existing Float callers keep working.

Notes:
- transformed(by:) takes float4x4; needs a Double overload (double4x4) or a generic matrix path.
- init(from: MDLAxisAlignedBoundingBox) only makes sense for Float; keep it constrained to Scalar == Float.
- Codable conformance should stay.
- Breaking changes are acceptable; bump the minor version.

- `2026-10-15T14:52:36Z`: Folded into #29 (generic vector-only types) under umbrella #32.

---

## 28: Add double4x4 overloads for matrix helpers

+++
status: closed
priority: low
kind: enhancement
labels: effort:s
created: 2026-10-15T14:46:48Z
updated: 2026-10-15T14:50:12Z
closed: 2026-10-15T14:50:12Z
+++

float4x4 helpers such as upperLeft3x3, normalMatrix, translation, init(translation:), init(scale:) exist only for Float. SwiftMesh's generic Mesh (SwiftMesh #57) needs upperLeft3x3 for Double. Add double4x4 equivalents, at least upperLeft3x3 and normalMatrix. SIMD4.xyz is already generic.

---

## 29: Generic: Angle, BoundingBox3D, Ray3D, Skew over Scalar (no matrix/quat work)

+++
status: new
priority: medium
kind: enhancement
labels: generics, effort:m, deferred
depends: 27
created: 2026-10-15T14:52:26Z
updated: 2026-10-15T14:53:16Z
+++

Make the vector-only parts generic over Scalar: BinaryFloatingPoint & SIMDScalar. No matrix or quaternion abstraction needed.

- Angle<Scalar> with typealias AngleF = Angle<Float>.
- BoundingBox3D<Scalar>. transformed(by: float4x4) and init(from: MDLAxisAlignedBoundingBox) stay in where Scalar == Float extensions; add transformed(by: double4x4) for Double.
- Ray3D<Scalar>: origin, direction, point(at:), triangle and box intersection. Clip-point and view-point inits stay where Scalar == Float.
- Skew<Scalar>.
- Generic SIMD3 helpers (normalized, scale(to:)). Generic code cannot call simd's dot/cross/length/normalize on SIMD3<Scalar>, so add small generic versions or a helper protocol.
- isApproximatelyEqual overloads for double4x4 and simd_quatd.
- Typealiases (BoundingBox3DF, Ray3DF, ...) so client stored properties keep compiling.
- Mark generic API @inlinable; check Float performance of Ray3D.intersect and Frustum.intersects did not regress.

---

## 30: Generic: GeometryScalar, SIMDMatrix4x4, SIMDQuaternion protocols

+++
status: new
priority: medium
kind: enhancement
labels: generics, effort:m, deferred
created: 2026-10-15T14:52:26Z
updated: 2026-10-15T14:53:16Z
+++

simd's float4x4/double4x4 and simd_quatf/simd_quatd share no generic protocol. Add our own:

- GeometryScalar: BinaryFloatingPoint & SIMDScalar & Sendable, with associated types Matrix4x4, Matrix3x3, Quaternion. Float and Double conform.
- SIMDMatrix4x4 / SIMDMatrix3x3: column init, column subscript, inverse, transpose, determinant, matrix*matrix, matrix*vector.
- SIMDQuaternion: init(angle:axis:), init(rotation matrix), vector, act(_:), *, slerp.

The simd types already provide these members, so the conformances should be mostly empty. Include tests that exercise each requirement for Float and Double, and @inlinable on everything.

---

## 31: Generic: port Transform3D, LookAt, Decomposition, Euler, lookRotation, rotation inits

+++
status: new
priority: low
kind: enhancement
labels: generics, effort:l, deferred
depends: 30
created: 2026-10-15T14:52:26Z
updated: 2026-10-15T14:53:16Z
+++

Once the GeometryScalar/SIMDMatrix4x4/SIMDQuaternion protocols exist, make these generic over Scalar: GeometryScalar:

- Transform3D (rotation: Scalar.Quaternion), init?(matrix:), matrix, interpolated.
- LookAt, orthonormalBasis/perpendicular, lookRotation.
- Decomposition / TransformComponents (272 lines ported from WebKit; the biggest piece).
- Euler and simd_quatf(Euler).
- Matrix helpers: x/y/zRotation inits (need generic Angle), translation, scale, upperLeft3x3, normalMatrix. These would replace the duplicated double4x4 helpers from #28.

Keep Float typealiases. Benchmark Float before and after.

Out of scope unless needed: Projection, ViewProjection, Frustum, CameraCone (GPU-facing, Float is fine).

---

## 32: Make GeometryLite3D generic over scalar type (umbrella)

+++
status: new
priority: medium
kind: enhancement
labels: generics, tracking, deferred
depends: 27, 29, 30, 31
created: 2026-10-15T14:52:43Z
updated: 2026-10-15T14:53:16Z
+++

Tracking issue for making the library work with Double as well as Float (needed by SwiftMesh's generic Mesh).

Easy (no matrix/quaternion abstraction):
- #29 Angle, BoundingBox3D, Ray3D, Skew over Scalar. #27 (BoundingBox3D generic) is part of this.

Hard (needs our own protocols, because simd matrix and quaternion types are not generic):
- #30 GeometryScalar, SIMDMatrix4x4, SIMDQuaternion protocols.
- #31 port Transform3D, LookAt, Decomposition, Euler, lookRotation, rotation inits (depends on #30).

Out of scope unless needed: Projection, ViewProjection, Frustum, CameraCone (GPU-facing, Float is fine).

Cross-cutting: keep Float typealiases (AngleF, BoundingBox3DF, ...) so clients keep compiling; mark generic API @inlinable and benchmark Float hot paths before and after.

---

## 33: Ray3D.intersect(box:) returns nil when the ray starts inside the box

+++
status: closed
priority: medium
kind: bug
labels: effort:s, area:ray
created: 2026-10-15T19:03:34Z
updated: 2026-10-15T19:06:57Z
closed: 2026-10-15T19:06:57Z
+++

Ray3D.intersect(box:) returns nil when the origin is inside the box (entry < 0). Callers cannot use it as a ray-vs-box overlap test, for example to cull meshes when the camera is inside their bounds. MetalSprocketsSceneGraph's hit test needs a hit at distance 0 in that case (with the normal opposite to the ray direction), and keeps its own slab test until then.

---

## 34: Ray3D.intersect(box:) gives NaN for an axis-parallel ray on a box face plane

+++
status: closed
priority: medium
kind: bug
labels: effort:s, area:ray
created: 2026-10-15T19:03:34Z
updated: 2026-10-15T19:06:39Z
closed: 2026-10-15T19:06:39Z
+++

intersect(box:) computes 1 / direction. When a direction component is 0 and the origin is exactly on the min or max plane of that axis, (box.min - origin) * inverseDirection is 0 * inf = NaN, and the result depends on how min/max handle NaN. Axis-aligned rays (such as straight down -Z) on a face plane are common in hit tests.

---

## 35: Ray3D.intersect(triangle:) misses small triangles

+++
status: closed
priority: medium
kind: bug
labels: effort:s, area:ray
created: 2026-10-15T19:03:34Z
updated: 2026-10-15T19:06:14Z
closed: 2026-10-15T19:06:14Z
+++

intersect(triangle:) rejects a hit when the determinant is less than 1e-7. Direction is normalized, so the determinant scales with the triangle's edge lengths squared. Triangles with edges near 1e-4 (millimetre-sized in metres) give a determinant near 1e-8 and are missed. MetalSprocketsSceneGraph uses 1e-12.

---

## 36: SIMD4.xyz and other SIMD helpers are slow when called from other modules

+++
status: closed
priority: medium
kind: bug
created: 2026-10-17T12:22:15Z
updated: 2026-10-17T12:23:42Z
closed: 2026-10-17T12:23:42Z
+++

The generic SIMD helpers in SIMD+Extensions.swift (SIMD4.xyz, SIMD3.xy, map, scalars) are not @inlinable. Other modules cannot specialize them, so every call goes through generic SIMD code and Swift metadata lookups. SIMD4.xyz also builds its result with an array literal (SIMD.init(arrayLiteral:)), which is slow in the unspecialized path.

Measured in MetalSprocketsSceneGraph (Release build, 1,600-entry scene): SIMD4.xyz, called once per entry per frame to read a translation, took about 8% of frame time (244 of 2,945 main-thread samples). Most of that time was in SIMD.init(arrayLiteral:), SIMD.init<A>(_:) and __swift_instantiateGenericMetadata.

---

## 37: No public API is @inlinable

+++
status: closed
priority: medium
kind: feature
created: 2026-10-17T12:22:15Z
updated: 2026-10-17T12:23:42Z
closed: 2026-10-17T12:23:42Z
+++

No declaration in GeometryLite3D is marked @inlinable. Small hot helpers (SIMD extensions, Transform3D.matrix, Frustum.intersects, bounds transforms, Packed3 conversions) cannot be inlined or specialized by client modules, so they cost a full cross-module call, and generic ones also run unspecialized code.

This shows up in per-frame renderer loops over thousands of entries (see the SIMD4.xyz issue for one measured case).

---

## 38: Closest point on a triangle to a point

+++
status: closed
priority: medium
kind: feature
labels: effort:s
created: 2026-10-19T15:24:09Z
updated: 2026-10-19T15:29:49Z
closed: 2026-10-19T15:29:49Z
+++

Add a function that returns the closest point on triangle (a, b, c) to a point p, plus its barycentric coordinates. Use the Voronoi-region method (Ericson, Real-Time Collision Detection, 5.1.5).

Acceptance: correct results for p closest to each vertex, each edge, and the face interior; degenerate triangles do not crash.

Needed by SwiftMesh #178 (closest point and distance from a point to a mesh).

---

## 39: Solid angle of a triangle seen from a point

+++
status: closed
priority: medium
kind: feature
labels: effort:xs
created: 2026-10-19T15:24:09Z
updated: 2026-10-19T15:29:49Z
closed: 2026-10-19T15:29:49Z
+++

Add a function that returns the signed solid angle of triangle (a, b, c) seen from a point p (Van Oosterom and Strackee formula). The sign follows the triangle winding.

Acceptance: an outward-wound closed cube gives a total of 4π from inside and 0 from outside; one face seen from the cube's center gives 4π/6.

Needed by SwiftMesh #179 (inside test by generalized winding number).

---

## 40: Make generic public helpers @inlinable

+++
status: closed
priority: medium
kind: enhancement
labels: performance
created: 2026-10-19T16:47:02Z
updated: 2026-10-19T18:36:38Z
closed: 2026-10-19T18:36:38Z
+++

Generic public API that is not @inlinable gets unspecialized calls through witness tables in client modules.

Add @inlinable to:
- Clamp.swift: clamped(to:)
- Wrap.swift: wrapped(to:)
- SIMD+Extensions.swift: xy, xyz, map, scalars
- SIMD+ApproximateEquality.swift: generic isApproximatelyEqual
- Packed3: init(x:y:z:), init(_:) conversions, subscript, *, init(arrayLiteral:)

---

## 41: Make small hot-path math @inlinable

+++
status: closed
priority: low
kind: enhancement
labels: performance
created: 2026-10-19T16:47:02Z
updated: 2026-10-19T18:36:38Z
closed: 2026-10-19T18:36:38Z
+++

Small non-generic public math is not @inlinable. SwiftPM's conservative cross-module optimization may not inline it.

Add @inlinable to:
- AngleF: operators, degrees, init(degrees:), init(radians:), radians(_:)
- Ray3D: init, point(at:), intersect(triangle:), intersect(box:), clip/view-point inits
- BoundingBox3D: init, center, size, radius, isEmpty, contains, union, transformed(by:)
- Frustum: init(viewProjection:), intersects(_:)
- ViewProjection: inits, matrix, project, unproject, clipPoint, viewPoint
- SIMD+Matrix+Extensions: remaining inits/accessors (translation, scale, rotations, normalMatrix, ...), lookRotation
- LookAt: init, cameraMatrix, viewMatrix
- Transform3D: init, matrix
- Projection: projectionMatrix variants, isReversedDepth, viewMatrix(eye:forward:up:)
- Triangle.swift: closestPoint, solidAngle (if used in inner loops)

Skip: stored properties, Codable, MDL init, Decomposition, Euler, CameraCone.

---

## 42: float4x4.decompose returns a wrong, non-unit rotation near 180° about x

+++
status: closed
priority: high
kind: bug
created: 2026-10-21T20:47:59Z
updated: 2026-10-21T20:55:41Z
closed: 2026-10-21T20:55:41Z
+++

In `Decomposition.swift`, the "Q_xx is largest" branch (taken when 1 + trace <= 0.001, that is near-180° rotations whose axis is closest to x) computes y with a difference instead of a sum:

```swift
// Q_xx is largest.
(column[1][0] - column[0][1]) * s,   // should be (column[1][0] + column[0][1]) * s
```

The Q_yy and Q_zz branches use sums for the off-axis terms, as they should.

Result: the rotation is wrong and not unit length. Composing a Transform3D from it scales the matrix by the squared length, so repeated decompose/compose round trips shrink the object. Found in MetalSprocketsSceneGraph: physics writes each body pose back through decompose every step, and dice shrank step after step.

Repro (float bit patterns logged from the dice demo):

```swift
let bits: [UInt32] = [0x3f86c96c, 0x3fb5b075, 0x3f1774cd,              // translation
                      0x3f6f0dd7, 0x3ddbc806, 0x3eae95cb, 0x3c7312b4,  // rotation x, y, z, w
                      0x3d80000b, 0x3d80000c, 0x3d800009]              // scale
let v = bits.map(Float.init(bitPattern:))
let pose = Transform3D(translation: [v[0], v[1], v[2]], rotation: simd_quatf(vector: [v[3], v[4], v[5], v[6]]), scale: [v[7], v[8], v[9]])
let once = pose.matrix.decompose!
// rotation in:  (0.934, 0.107, 0.341, w 0.0148), length 1
// rotation out: (0.934, -0.005, 0.341, w 0.0148), length 0.99424
let twice = Transform3D(translation: once.translation, rotation: once.rotation, scale: once.scale).matrix.decompose!
// scale: 0.0625 in, 0.06178 after the second round trip
```

Done when: decompose round-trips rotations in all four branches (trace branch and each largest-diagonal branch), checked by comparing rotations (q or -q), not just scale or length. MetalSprocketsSceneGraph currently normalizes the rotation in Transform3D(decomposing:) as a workaround, which hides the shrink but not the wrong rotation.

---
