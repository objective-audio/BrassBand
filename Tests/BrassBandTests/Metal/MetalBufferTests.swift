import Testing

@testable import BrassBand

@MainActor
struct MetalBufferTests {
    @Test(
        .enabled(if: isMetalSystemAvailable),
        arguments: [
            (0, false),
            (1, true),
            (256, true),
        ]
    )
    func initialize(length: Int, success: Bool) async throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let metalBuffer = MetalBuffer(device: device, length: length)

        if success {
            let metalBuffer = try #require(metalBuffer)
            #expect(metalBuffer.mtl.length == length)
        } else {
            #expect(metalBuffer == nil)
        }
    }

    @Test(.enabled(if: isMetalSystemAvailable))
    func writeWithType() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())

        let metalBuffer = try #require(
            MetalBuffer(device: device, length: 4 * MemoryLayout<Index2d>.size))

        let sourceBuffer = UnsafeMutableBufferPointer<Index2d>.allocate(capacity: 2)

        sourceBuffer.withMemoryRebound(to: Index2d.self) { buffer in
            buffer[0] = 1
            buffer[1] = 2
        }

        metalBuffer.write(from: .init(sourceBuffer), dynamicBufferIndex: 0)

        metalBuffer.mtl.contents().withMemoryRebound(to: Index2d.self, capacity: 4) { pointer in
            #expect(pointer[0] == 1)
            #expect(pointer[1] == 2)
            #expect(pointer[2] == 0)
            #expect(pointer[3] == 0)
        }

        sourceBuffer.withMemoryRebound(to: Index2d.self) { buffer in
            buffer[0] = 3
            buffer[1] = 4
        }

        metalBuffer.write(from: UnsafeBufferPointer<Index2d>(sourceBuffer), dynamicBufferIndex: 1)

        metalBuffer.mtl.contents().withMemoryRebound(to: Index2d.self, capacity: 4) { pointer in
            #expect(pointer[0] == 1)
            #expect(pointer[1] == 2)
            #expect(pointer[2] == 3)
            #expect(pointer[3] == 4)
        }
    }

    @Test(.enabled(if: isMetalSystemAvailable))
    func writeWithoutType() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())

        let metalBuffer = try #require(
            MetalBuffer(device: device, length: 4 * MemoryLayout<Index2d>.size))

        let sourceBuffer = UnsafeMutableBufferPointer<Index2d>.allocate(capacity: 2)

        sourceBuffer.withMemoryRebound(to: Index2d.self) { buffer in
            buffer[0] = 1
            buffer[1] = 2
        }

        metalBuffer.write(from: UnsafeRawBufferPointer(sourceBuffer), dynamicBufferIndex: 0)

        metalBuffer.mtl.contents().withMemoryRebound(to: Index2d.self, capacity: 4) { pointer in
            #expect(pointer[0] == 1)
            #expect(pointer[1] == 2)
            #expect(pointer[2] == 0)
            #expect(pointer[3] == 0)
        }

        sourceBuffer.withMemoryRebound(to: Index2d.self) { buffer in
            buffer[0] = 3
            buffer[1] = 4
        }

        metalBuffer.write(from: UnsafeRawBufferPointer(sourceBuffer), dynamicBufferIndex: 1)

        metalBuffer.mtl.contents().withMemoryRebound(to: Index2d.self, capacity: 4) { pointer in
            #expect(pointer[0] == 1)
            #expect(pointer[1] == 2)
            #expect(pointer[2] == 3)
            #expect(pointer[3] == 4)
        }
    }
}
