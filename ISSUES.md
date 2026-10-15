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
