import GeometryLite3D
import simd
import Testing

struct DeprecatedNamesTests {
    @Test
    @available(*, deprecated)
    func depthModeAliases() {
        #expect(PerspectiveProjection.DepthMode.reversed(zMin: 0.5) == .reversedInfinite(zNear: 0.5))
        #expect(PerspectiveProjection.DepthMode.reversedFinite(zClip: 1...10) == .reversed(zClip: 1...10))
    }

    @Test
    @available(*, deprecated)
    func transformComponentsTranslateAlias() {
        var components = TransformComponents(perspective: [0, 0, 0, 1], translate: [1, 2, 3], scale: .one, skew: .zero, rotation: .identity)
        #expect(components.translation == [1, 2, 3])
        components.translate = [4, 5, 6]
        #expect(components.translate == [4, 5, 6])
    }

    @Test
    @available(*, deprecated)
    func boundingBoxAlias() {
        let box: BoundingBox = BoundingBox3D(min: .zero, max: .one)
        #expect(box.size == .one)
    }
}
