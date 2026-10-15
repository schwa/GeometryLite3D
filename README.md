# GeometryLite3D

Lightweight Swift package providing essential 3D geometry utilities for SIMD-based graphics programming. Built with Float types for seamless Metal integration while offering generic implementations where appropriate.

## Installation

Add GeometryLite3D to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/schwa/GeometryLite3D.git", from: "0.1.1")
]
```

Then add it as a dependency to your target:

```swift
.target(name: "YourTarget", dependencies: ["GeometryLite3D"])
```

## Features

- **AngleF**: Type-safe angle representation with degree/radian conversion
- **Transform3D**: Translation, rotation (quaternion), and scale, with matrix conversion and interpolation
- **BoundingBox3D**: Axis-aligned bounding box with union, center, size, contains, and transformation
- **Projection**: Perspective and orthographic projections with standard or reversed 0...1 depth
- **LookAt**: Camera and view matrices, plus `simd_quatf.lookRotation` and `float4x4.viewMatrix(eye:forward:up:)`
- **Ray3D**: Rays from view or clip points, with triangle and box intersection
- **Frustum**: Conservative bounding box culling
- **SIMD Extensions**: Rotation, translation, and scale matrices; `translation`, `upperLeft3x3`, `normalMatrix`, `isMirroring`
- **Decomposition**: Matrix decomposition into perspective, translation, scale, skew, and rotation
- **Utilities**: Euler angles, clamping, wrapping, packed 3D vector types, and approximate equality

## Usage

### Angles

```swift
import GeometryLite3D

let angle = AngleF.degrees(45)
let radians = angle.radians  // 0.785398...

let sum = AngleF.degrees(30) + AngleF.degrees(60)
```

### Transformations

```swift
// Create transformation matrices
let rotation = float4x4(yRotation: .degrees(45))
let translation = float4x4(translation: [10, 0, 5])
let scale = float4x4(scale: [2, 2, 2])

// Combine transformations
let transform = translation * rotation * scale
```

### Camera and Projection

```swift
// Set up camera view
let lookAt = LookAt(position: [0, 5, 10], target: [0, 0, 0], up: [0, 1, 0])
let viewMatrix = lookAt.viewMatrix

// Create perspective projection (clip z 0...1, near at 0)
let projection = PerspectiveProjection(verticalAngleOfView: .degrees(60), depthMode: .standard(zClip: 0.1...1000))
let projectionMatrix = projection.projectionMatrix(aspectRatio: 16.0 / 9.0)

// Orthographic projection
let orthographic = OrthographicProjection(halfHeight: 5, depthMode: .standard(zClip: 0.1...100))
```

All projections give clip z in 0...1, as Metal expects. The `.reversed` and `.reversedFinite` depth modes put the near plane at 1 and the far plane at 0. To use them, set the depth compare function to `.greater` and clear depth to 0.

### Transforms

```swift
let transform = Transform3D(translation: [0, 1, 0], rotation: simd_quatf(angle: .pi / 2, axis: [0, 1, 0]), scale: [2, 2, 2])
let matrix = transform.matrix
let halfway = Transform3D.identity.interpolated(to: transform, amount: 0.5)
```

### Bounding Boxes

```swift
let box = BoundingBox3D(min: [-1, -1, -1], max: [1, 1, 1])
let transformedBox = box.transformed(by: transform.matrix)
let combined = box.union(transformedBox)
let center = combined.center
```

### Picking and Culling

```swift
let ray = Ray3D(viewPoint: [100, 200], viewSize: [800, 600], viewMatrix: viewMatrix, projectionMatrix: projectionMatrix)
if let hit = ray.intersect(triangle: a, b, c) {
    print(hit.distance, hit.barycentrics)
}

let frustum = Frustum(viewProjection: projectionMatrix * viewMatrix)
let visible = frustum.intersects(box)
```

## Requirements

- Swift 6.1+
- macOS 15.0+, iOS 18.0+, tvOS 18.0+, watchOS 11.0+, visionOS 2.0+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.