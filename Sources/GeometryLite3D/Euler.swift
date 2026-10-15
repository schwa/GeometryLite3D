import Foundation
import simd

public struct Euler {
    public enum Order {
        case zyx
    }

    public var order: Order = .zyx
    public var roll: Float
    public var pitch: Float
    public var yaw: Float
}

public extension Euler {
    init(_ q: simd_quatf) {
        // ZYX order: yaw (Z), pitch (Y), roll (X), in radians.
        let x = q.imag.x
        let y = q.imag.y
        let z = q.imag.z
        let w = q.real

        // Roll (x-axis rotation)
        let sinrCosp = 2 * (w * x + y * z)
        let cosrCosp = 1 - 2 * (x * x + y * y)
        roll = atan2(sinrCosp, cosrCosp)

        // Pitch (y-axis rotation)
        let sinp = 2 * (w * y - z * x)
        if abs(sinp) >= 1 {
            // If sinp is out of range, clamp pitch to 90 degrees.
            pitch = copysign(.pi / 2, sinp)
        } else {
            pitch = asin(sinp)
        }

        // Yaw (z-axis rotation)
        let sinyCosp = 2 * (w * z + x * y)
        let cosyCosp = 1 - 2 * (y * y + z * z)
        yaw = atan2(sinyCosp, cosyCosp)
    }
}
