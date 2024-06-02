import MetalPerformanceShaders
import Testing
import os

@testable import BrassBand

extension KernelStub: Blur.MetalKernel {}

private struct MetalSystemStub: Blur.MetalSystem {
    let makeHandler: (_ sigma: Double) -> Void
    let kernelEncodeHandler: @Sendable () -> Void

    func makeMetalBlurKernel(sigma: Double) -> any Blur.MetalKernel {
        makeHandler(sigma)
        return KernelStub(encodeHandler: kernelEncodeHandler)
    }
}

private struct EmptySystemStub: RenderSystem {}

private struct CommandBufferStub: CommandBuffer {}

private struct ThroughEncoderStub: Effect.Encodable {
    let encodeHandler: () -> Void

    func encode(
        sourceTexture: Texture, destinationTexture: Texture,
        system: any RenderSystem, commandBuffer: any CommandBuffer
    ) throws {
        encodeHandler()
    }
}

@MainActor
struct BlurTests {
    @Test func sigma() throws {
        let blur = Blur()

        #expect(blur.sigma == 0.0)

        let encoder = try #require(blur.effect.encoder as? Blur.EffectEncoder)

        #expect(encoder.sigma == 0.0)

        encoder.sigma = 1.0

        #expect(encoder.sigma == 1.0)
    }

    @Test func encode() throws {
        enum Called: Equatable {
            case makeKernel(sigma: Double)
            case kernelEncode
        }

        let called = OSAllocatedUnfairLock(initialState: [Called]())

        let blur = Blur()

        let scaleFactor = ScaleFactorProviderStub()
        let sourceTexture = Texture(
            pointSize: .init(width: 1, height: 1), scaleFactorProvider: scaleFactor)
        let destinationTexture = Texture(
            pointSize: .init(width: 1, height: 1), scaleFactorProvider: scaleFactor)
        let metalSystem = MetalSystemStub(
            makeHandler: { sigma in
                called.withLock { $0.append(.makeKernel(sigma: sigma)) }
            },
            kernelEncodeHandler: {
                called.withLock { $0.append(.kernelEncode) }
            })
        let emptySystem = EmptySystemStub()
        let commandBuffer = CommandBufferStub()

        let effect = blur.effect
        effect.set(sourceTexture: sourceTexture, destinationTexture: destinationTexture)

        #expect(called.withLock(\.self).count == 0)

        try effect.prepareForRendering(metalSystem)

        // sigmaが0でkernelを作成してencode

        try effect.encode(commandBuffer)

        #expect(called.withLock(\.self) == [.makeKernel(sigma: 0.0), .kernelEncode])
        called.withLock { $0.removeAll() }

        // sigmaが0以外になりkernelを再作成をしてencodeする

        blur.sigma = 1.0

        try effect.encode(commandBuffer)

        #expect(called.withLock(\.self) == [.makeKernel(sigma: 1.0), .kernelEncode])
        called.withLock { $0.removeAll() }

        // kernel作成済みならencodeのみ

        try effect.encode(commandBuffer)

        #expect(called.withLock(\.self) == [.kernelEncode])
        called.withLock { $0.removeAll() }

        // sigmaを変更したらkernelが作り直される

        blur.sigma = 0.5

        try effect.encode(commandBuffer)

        #expect(called.withLock(\.self) == [.makeKernel(sigma: 0.5), .kernelEncode])
        called.withLock { $0.removeAll() }

        // scaleFactorを変更したらkernelが作り直される

        scaleFactor.scaleFactor = 2.0
        try effect.encode(commandBuffer)

        #expect(called.withLock(\.self) == [.makeKernel(sigma: 1.0), .kernelEncode])
        called.withLock { $0.removeAll() }

        // 対応していないSystemならkernelの生成ができずエラーになる

        blur.sigma = 1.0

        try effect.prepareForRendering(emptySystem)

        #expect(throws: Blur.Error.makeKernelFailed) {
            try effect.encode(commandBuffer)
        }

        #expect(called.withLock(\.self).isEmpty)
    }

    @Test(
        .enabled(if: isMetalSystemAvailable),
        arguments: [
            (sigma: 0.0, isBlurKernel: false),
            (sigma: 0.5, isBlurKernel: true),
            (sigma: 1.0, isBlurKernel: true),
        ]
    )
    func makeBlurKernel(sigma: Double, isBlurKernel: Bool) throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))
        let kernel = try #require(system.makeMetalBlurKernel(sigma: sigma) as? MetalKernel)

        if isBlurKernel {
            let blurKernel = try #require(kernel.raw as? MPSImageGaussianBlur)
            #expect(blurKernel.sigma == Float(sigma))
        } else {
            #expect(kernel.raw is Effect.Through.MetalRawKernel)
        }
    }
}
