import Testing
import os

@testable import BrassBand

private struct CommandBufferStub: CommandBuffer {}

extension KernelStub: Effect.Through.MetalKernel {}

private struct MetalSystemStub: Effect.Through.MetalSystem {
    let makeKernelHandler: () -> Void
    let kernelEncodeHandler: @Sendable () -> Void

    func makeMetalThroughKernel() -> any Effect.Through.MetalKernel {
        makeKernelHandler()
        return KernelStub(encodeHandler: kernelEncodeHandler)
    }
}

@MainActor
struct ThroughEffectTests {
    @Test func encode() throws {
        enum Called {
            case makeKernel
            case kernelEncode
        }

        let called = OSAllocatedUnfairLock(initialState: [Called]())

        let scaleFactorProvider = ScaleFactorProviderStub()
        let sourceTexture = Texture(
            pointSize: .init(repeating: 1), scaleFactorProvider: scaleFactorProvider)
        let destinationTexture = Texture(
            pointSize: .init(repeating: 1), scaleFactorProvider: scaleFactorProvider)
        let system = MetalSystemStub(
            makeKernelHandler: {
                called.withLock { $0.append(.makeKernel) }
            },
            kernelEncodeHandler: {
                called.withLock { $0.append(.kernelEncode) }
            })
        let commandBuffer = CommandBufferStub()

        let through = Effect.Through()

        #expect(called.withLock(\.self).isEmpty)

        try through.encode(
            sourceTexture: sourceTexture, destinationTexture: destinationTexture, system: system,
            commandBuffer: commandBuffer)

        #expect(called.withLock(\.self) == [.makeKernel, .kernelEncode])
        called.withLock { $0.removeAll() }

        try through.encode(
            sourceTexture: sourceTexture, destinationTexture: destinationTexture, system: system,
            commandBuffer: commandBuffer)

        #expect(called.withLock(\.self) == [.kernelEncode])
    }

    @Test(.enabled(if: isMetalSystemAvailable))
    func encodeWithActualMetalSystem() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))
        let scaleFactorProvider = ScaleFactorProviderStub()
        let commandQueue = try #require(device.makeCommandQueue())
        let commandBuffer = try #require(commandQueue.makeCommandBuffer())
        let metalCommandBuffer = MetalCommandBuffer(value: commandBuffer)

        let sourceTexture = Texture(
            pointSize: .init(repeating: 1), scaleFactorProvider: scaleFactorProvider)
        let destinationTexture = Texture(
            pointSize: .init(repeating: 1), scaleFactorProvider: scaleFactorProvider)

        try sourceTexture.prepareForRendering(system: system)
        try destinationTexture.prepareForRendering(system: system)

        let through = Effect.throughEncoder

        try through.encode(
            sourceTexture: sourceTexture, destinationTexture: destinationTexture, system: system,
            commandBuffer: metalCommandBuffer)
    }
}
