# GeometryLite3D

Lightweight Swift package providing essential 3D geometry utilities for SIMD-based graphics programming. Built with Float types for seamless Metal integration while offering generic implementations where appropriate.

## Installation

Add GeometryLite3D to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/USERNAME/GeometryLite3D.git", from: "1.0.0")
]
```

Then add it as a dependency to your target:

```swift
.target(name: "YourTarget", dependencies: ["GeometryLite3D"])
```

## Features

- **AngleF**: Type-safe angle representation with degree/radian conversion
- **BoundingBox**: Axis-aligned bounding box with transformation support
- **Projection**: Perspective and orthographic projection matrices
- **LookAt**: Camera view matrix generation
- **SIMD Extensions**: Convenience initializers for transformation matrices
- **Decomposition**: Matrix decomposition into translation, rotation, and scale
- **Utilities**: Clamping, wrapping, and packed 3D vector types

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

// Create perspective projection
let projection = PerspectiveProjection(verticalAngleOfView: .degrees(60), zClip: 0.1...1000)
let projectionMatrix = projection.projectionMatrix(aspectRatio: 16.0/9.0)
```

### Bounding Boxes

```swift
let box = BoundingBox(min: [-1, -1, -1], max: [1, 1, 1])
let transformedBox = box.transformed(by: transform)
```

## Requirements

- Swift 6.1+
- macOS 15.0+, iOS 18.0+, tvOS 18.0+, watchOS 11.0+, visionOS 2.0+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.