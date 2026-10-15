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
updated: 2026-10-15T13:58:47Z
closed: 2026-10-15T13:58:47Z
+++

Projection.swift marks float4x4.perspective with '// TODO: OLD'. It gives the same matrix as PerspectiveProjection(verticalAngleOfView:depthMode: .standard(zClip:)), and also uses OpenGL clip z (see #11). Mark it @available(*, deprecated) pointing at PerspectiveProjection, then remove it in a later release. Check dependents (MetalSprocketsSceneGraph, MetalSprocketsPBR) for callers first.

- `2026-10-15T13:58:47Z`: Deprecated, not removed. Remaining callers: MetalSprocketsAddOns TransformsTests.swift:17 and MetalSprocketsExamples MeshDissolveDemoView.swift:46. Remove after those move to PerspectiveProjection.

---
