import BrassBandCpp
import Foundation
import MetalKit
import MetalPerformanceShaders
import simd

@MainActor
public final class MetalSystem {
    enum Error: Swift.Error {
        case makeMetalBufferFailed
        case makeMTLTextureFailed
        case makeMTLSamplerStateFailed
    }

    private static let uniformsBufferCount: Int = MetalConstants.framesInFlight
    private static let depthPixelFormat: MTLPixelFormat = .invalid
    private static let stencilPixelFormat: MTLPixelFormat = .invalid

    public let device: any MTLDevice
    private let commandQueue: any MTLCommandQueue
    private let defaultLibrary: any MTLLibrary
    private let fragmentFunctionWithTexture: any MTLFunction
    private let fragmentFunctionWithoutTexture: any MTLFunction
    private let vertexFunction: any MTLFunction
    private let multiSamplePipelineStateWithTexture: any MTLRenderPipelineState
    private let multiSamplePipelineStateWithoutTexture: any MTLRenderPipelineState
    private let pipelineStateWithTexture: any MTLRenderPipelineState
    private let pipelineStateWithoutTexture: any MTLRenderPipelineState

    private let view: MetalView
    public let sampleCount: Int
    private let inflightSemaphore: DispatchSemaphore

    private var uniformsBuffers = [(any MTLBuffer)?](
        repeating: nil, count: Int(uniformsBufferCount))
    private var uniformsBufferIndex: Int = 0
    private var uniformsBufferOffset: Int = 0

    public private(set) var lastEncodedMeshCount: Int = 0

    public init?(device: any MTLDevice, view: MetalView, sampleCount: Int = 1) {
        guard let commandQueue = device.makeCommandQueue(),
            let defaultLibrary = ShaderBundle.defaultMetalLibrary(device: device),
            let fragmentFunctionWithTexture = defaultLibrary.makeFunction(
                name: "fragment2d_with_texture"),
            let fragmentFunctionWithoutTexture = defaultLibrary.makeFunction(
                name: "fragment2d_without_texture"),
            let vertexFunction = defaultLibrary.makeFunction(name: "vertex2d")
        else {
            return nil
        }

        let colorDescription = MTLRenderPipelineColorAttachmentDescriptor()
        colorDescription.pixelFormat = .bgra8Unorm
        colorDescription.isBlendingEnabled = true
        colorDescription.rgbBlendOperation = .add
        colorDescription.alphaBlendOperation = .add
        colorDescription.sourceRGBBlendFactor = .one
        colorDescription.sourceAlphaBlendFactor = .one
        colorDescription.destinationRGBBlendFactor = .oneMinusSourceAlpha
        colorDescription.destinationAlphaBlendFactor = .oneMinusSourceAlpha

        let pipelineStateDescription = MTLRenderPipelineDescriptor()
        pipelineStateDescription.rasterSampleCount = sampleCount
        pipelineStateDescription.vertexFunction = vertexFunction
        pipelineStateDescription.colorAttachments[0] = colorDescription
        pipelineStateDescription.depthAttachmentPixelFormat = Self.depthPixelFormat
        pipelineStateDescription.stencilAttachmentPixelFormat = Self.stencilPixelFormat

        pipelineStateDescription.fragmentFunction = fragmentFunctionWithTexture

        guard
            let multiSamplePipelineStateWithTexture = try? device.makeRenderPipelineState(
                descriptor: pipelineStateDescription)
        else {
            return nil
        }

        pipelineStateDescription.fragmentFunction = fragmentFunctionWithoutTexture

        guard
            let multiSamplePipelineStateWithoutTexture = try? device.makeRenderPipelineState(
                descriptor: pipelineStateDescription)
        else {
            return nil
        }

        pipelineStateDescription.rasterSampleCount = 1

        guard
            let pipelineStateWithoutTexture = try? device.makeRenderPipelineState(
                descriptor: pipelineStateDescription)
        else {
            return nil
        }

        pipelineStateDescription.fragmentFunction = fragmentFunctionWithTexture

        guard
            let pipelineStateWithTexture = try? device.makeRenderPipelineState(
                descriptor: pipelineStateDescription)
        else {
            return nil
        }

        self.device = device
        self.commandQueue = commandQueue
        self.defaultLibrary = defaultLibrary
        self.fragmentFunctionWithTexture = fragmentFunctionWithTexture
        self.fragmentFunctionWithoutTexture = fragmentFunctionWithoutTexture
        self.vertexFunction = vertexFunction
        self.multiSamplePipelineStateWithTexture = multiSamplePipelineStateWithTexture
        self.multiSamplePipelineStateWithoutTexture = multiSamplePipelineStateWithoutTexture
        self.pipelineStateWithTexture = pipelineStateWithTexture
        self.pipelineStateWithoutTexture = pipelineStateWithoutTexture

        self.view = view
        self.sampleCount = sampleCount
        self.inflightSemaphore = DispatchSemaphore(value: MetalConstants.framesInFlight)
    }

    func prepareUniformsBuffer(uniformsCount: Int) {
        let preferredLength = uniformsCount * uniforms2dSize
        let actualLength =
            preferredLength - (preferredLength % uniformsBufferAllocatingUnit)
            + uniformsBufferAllocatingUnit

        var needsAllocate = false

        if let currentBuffer = uniformsBuffers[Int(uniformsBufferIndex)] {
            if currentBuffer.length < actualLength {
                needsAllocate = true
            }
        } else {
            needsAllocate = true
        }

        if needsAllocate {
            uniformsBuffers[uniformsBufferIndex] = device.makeBuffer(length: actualLength)
        }
    }

    func makeMetalBuffer(length: Int) throws -> MetalBuffer {
        guard let buffer = MetalBuffer(device: device, length: length) else {
            throw Error.makeMetalBufferFailed
        }
        return buffer
    }

    func makeMetalTexture(actualSize: UIntSize, usage: TextureUsage, pixelFormat: PixelFormat)
        throws
        -> MetalTexture
    {
        try MetalTexture(
            actualSize: actualSize, usage: usage, pixelFormat: pixelFormat, system: self)
    }

    func makeMTLTexture(descriptor: MTLTextureDescriptor) throws -> any MTLTexture {
        guard let texture = device.makeTexture(descriptor: descriptor) else {
            throw Error.makeMTLTextureFailed
        }
        return texture
    }

    func makeMTLSamplerState(descriptor: MTLSamplerDescriptor) throws -> any MTLSamplerState {
        guard let samplerState = device.makeSamplerState(descriptor: descriptor) else {
            throw Error.makeMTLSamplerStateFailed
        }
        return samplerState
    }

    func makeMTLArgumentEncoder() -> any MTLArgumentEncoder {
        fragmentFunctionWithTexture.makeArgumentEncoder(bufferIndex: 0)
    }

    private func renderNodes(
        projectionMatrix: simd_float4x4, rootNode: Node,
        detector: any DetectorForRenderInfo,
        commandBuffer: any MTLCommandBuffer,
        renderPassDescriptor: MTLRenderPassDescriptor
    ) {
        let encoder = MetalEncoder()

        encoder.pushEncodeInfo(
            .init(
                renderPassDescriptor: renderPassDescriptor,
                pipelineStateWithTexture: multiSamplePipelineStateWithTexture,
                pipelineStateWithoutTexture: multiSamplePipelineStateWithoutTexture))

        do {
            try rootNode.prepareForRendering(system: self)
        } catch {
            print("prepareForRendering failed:\(error)")
            return
        }

        var renderInfo = NodeRenderInfo(
            matrix: projectionMatrix, meshMatrix: projectionMatrix, detector: detector,
            encodable: encoder, effectable: encoder, stackable: encoder)

        rootNode.buildRenderInfo(&renderInfo)

        let result = encoder.encode(
            system: self, commandBuffer: MetalCommandBuffer(value: commandBuffer))
        lastEncodedMeshCount = result.encodedMeshCount
    }

    func meshEncode(
        mesh: Mesh, encoder: any MTLRenderCommandEncoder, encodeInfo: MetalEncodeInfo
    ) {
        guard let currentUniformsBuffer = uniformsBuffers[uniformsBufferIndex] else {
            return
        }

        let contents = currentUniformsBuffer.contents()
        let content = contents.advanced(by: uniformsBufferOffset)
        let uniforms = content.assumingMemoryBound(to: Uniforms2d.self)
        uniforms.pointee.matrix = mesh.matrix
        uniforms.pointee.color = mesh.color.simd4
        uniforms.pointee.isMeshColorUsed = mesh.isMeshColorUsed

        mesh.encode(
            encoder: encoder, encodeInfo: encodeInfo, currentUniformsBuffer: currentUniformsBuffer,
            uniformsBufferOffset: uniformsBufferOffset)

        uniformsBufferOffset += uniforms2dSize

        assert((uniformsBufferOffset + uniforms2dSize) <= currentUniformsBuffer.length)
    }

    func pushEncodeInfo(renderPassDescriptor: MTLRenderPassDescriptor, encoder: any RenderStackable)
    {
        encoder.pushEncodeInfo(
            MetalEncodeInfo(
                renderPassDescriptor: renderPassDescriptor,
                pipelineStateWithTexture: pipelineStateWithTexture,
                pipelineStateWithoutTexture: pipelineStateWithoutTexture))
    }
}

extension MetalSystem: Renderer.System {
    public func viewRender(
        projectionMatrix: simd_float4x4, rootNode: Node, detector: any DetectorForRenderInfo
    ) {
        inflightSemaphore.wait()
        guard
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer()
        else {
            inflightSemaphore.signal()
            return
        }

        commandBuffer.addCompletedHandler { @Sendable [inflightSemaphore] _ in
            inflightSemaphore.signal()
        }

        uniformsBufferOffset = 0

        renderNodes(
            projectionMatrix: projectionMatrix, rootNode: rootNode, detector: detector,
            commandBuffer: commandBuffer,
            renderPassDescriptor: renderPassDescriptor)

        uniformsBufferIndex = (uniformsBufferIndex + 1) % Self.uniformsBufferCount

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
