import Testing

@testable import BrassBand

@MainActor
@Suite(.enabled(if: isMetalSystemAvailable))
struct MetalSystemTests {
    let device: MTLDevice
    let system: MetalSystem

    init() throws {
        device = try #require(MTLCreateSystemDefaultDevice())
        system = try #require(MetalSystem(device: device, view: MetalView(), sampleCount: 4))
    }

    @Test func initialize() {
        #expect(system.device === device)
        #expect(system.sampleCount == 4)
    }

    @Test func prepareUniformsBuffer_smoke() {
        system.prepareUniformsBuffer(uniformsCount: 1)
        system.prepareUniformsBuffer(uniformsCount: uniformsBufferAllocatingUnit - 1)
        system.prepareUniformsBuffer(uniformsCount: uniformsBufferAllocatingUnit)
    }

    @Test func renderNodes() {
        #warning("todo")
    }

    @Test func meshEncode() {
        #warning("todo")
    }

    @Test func pushEncodeInfo() {
        #warning("todo")
    }

    @Test func viewRender() {
        #warning("todo")
    }
}
