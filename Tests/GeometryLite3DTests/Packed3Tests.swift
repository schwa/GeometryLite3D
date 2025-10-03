import Testing
import simd
@testable import GeometryLite3D

struct Packed3Tests {
    @Test
    func initialization() {
        let packed = Packed3<Float>(x: 1, y: 2, z: 3)
        #expect(packed.x == 1)
        #expect(packed.y == 2)
        #expect(packed.z == 3)
    }

    @Test
    func arrayLiteralInitialization() {
        let packed: Packed3<Float> = [4, 5, 6]
        #expect(packed.x == 4)
        #expect(packed.y == 5)
        #expect(packed.z == 6)
    }

    @Test
    func subscriptAccess() {
        var packed = Packed3<Float>(x: 10, y: 20, z: 30)
        #expect(packed[0] == 10)
        #expect(packed[1] == 20)
        #expect(packed[2] == 30)

        packed[0] = 100
        packed[1] = 200
        packed[2] = 300
        #expect(packed.x == 100)
        #expect(packed.y == 200)
        #expect(packed.z == 300)
    }

    @Test
    func subscriptInvalidAccess() async {
        await #expect(processExitsWith: .failure) {
            let packed = Packed3<Float>(x: 10, y: 20, z: 30)
            print(packed[3] == 30)
        }
        await #expect(processExitsWith: .failure) {
            var packed = Packed3<Float>(x: 10, y: 20, z: 30)
            packed[3] = 30
        }
    }


    @Test
    func subscriptReadWriteCoversAllIndices() {
        var packed = Packed3<Double>(x: 0, y: 0, z: 0)
        let expected: [Double] = [3.5, -7.25, 11.0]

        for (index, value) in expected.enumerated() {
            packed[index] = value
        }

        for (index, value) in expected.enumerated() {
            #expect(packed[index] == value)
        }
    }

    @Test
    func multiplicationWithScalar() {
        let packed = Packed3<Float>(x: 2, y: 3, z: 4)
        let result = packed * 2
        #expect(result.x == 4)
        #expect(result.y == 6)
        #expect(result.z == 8)
    }

    @Test
    func conversionFromSIMD3() {
        let simd = SIMD3<Float>(10, 20, 30)
        let packed = Packed3<Float>(simd)
        #expect(packed.x == 10)
        #expect(packed.y == 20)
        #expect(packed.z == 30)
    }

    @Test
    func conversionToSIMD3() {
        let packed = Packed3<Float>(x: 5, y: 10, z: 15)
        let simd = SIMD3(packed)
        #expect(simd.x == 5)
        #expect(simd.y == 10)
        #expect(simd.z == 15)
    }

    @Test
    func simdRoundTrip() {
        let original = SIMD3<Float>(-4, 2, 9)
        let packed = Packed3<Float>(original)
        let recovered = SIMD3(packed)
        #expect(recovered == original)
    }

    @Test
    func multiplicationWithIntegerScalars() {
        let packed = Packed3<Int>(x: 1, y: -2, z: 3)
        let result = packed * 3
        #expect(result.x == 3)
        #expect(result.y == -6)
        #expect(result.z == 9)
    }

    @Test
    func copyInitialization() {
        let original = Packed3<Float>(x: 7, y: 8, z: 9)
        let copy = Packed3<Float>(x: original.x, y: original.y, z: original.z)
        #expect(copy.x == 7)
        #expect(copy.y == 8)
        #expect(copy.z == 9)
    }

    @Test
    func equality() {
        let packed1 = Packed3<Float>(x: 1, y: 2, z: 3)
        let packed2 = Packed3<Float>(x: 1, y: 2, z: 3)
        let packed3 = Packed3<Float>(x: 4, y: 5, z: 6)

        #expect(packed1 == packed2)
        #expect(packed1 != packed3)
    }

    #if os(iOS) || (os(macOS) && !arch(x86_64))
    @Test
    func float16Conversion() {
        let floatPacked = Packed3<Float>(x: 1.5, y: 2.5, z: 3.5)
        let float16Packed = Packed3<Float16>(floatPacked)
        #expect(float16Packed.x == 1.5)
        #expect(float16Packed.y == 2.5)
        #expect(float16Packed.z == 3.5)

        let backToFloat = Packed3<Float>(float16Packed)
        #expect(backToFloat.x == 1.5)
        #expect(backToFloat.y == 2.5)
        #expect(backToFloat.z == 3.5)
    }

    @Test
    func float16InitializerFromSIMD() {
        let simd = SIMD3<Float>(-0.25, 0.5, 1.75)
        let float16Packed = Packed3<Float16>(simd)
        #expect(float16Packed.x == -0.25)
        #expect(float16Packed.y == 0.5)
        #expect(float16Packed.z == 1.75)

        let roundTrip = SIMD3<Float>(Packed3<Float>(float16Packed))
        #expect(roundTrip.isApproximatelyEqual(to: simd, absoluteTolerance: 1e-3))
    }
    #endif
}
