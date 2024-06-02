import Synchronization
import Testing

@testable import BrassBand

@MainActor
struct TextureTests {
    @Test func initialize() {
        let provider = ScaleFactorProviderStub(scaleFactor: 2.0)
        let texture = Texture(pointSize: .init(width: 2, height: 1), scaleFactorProvider: provider)

        #expect(texture.pointSize == .init(width: 2, height: 1))
        #expect(texture.actualSize == .init(width: 4, height: 2))
        #expect(texture.scaleFactor == 2.0)
        #expect(texture.metalTexture == nil)
    }

    @Test(.enabled(if: isMetalSystemAvailable))
    func addElement() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))
        let provider = ScaleFactorProviderStub(scaleFactor: 1.0)

        let texture = Texture(pointSize: .init(width: 8, height: 8), scaleFactorProvider: provider)
        try texture.prepareForRendering(system: system)

        let drawHandler: ImageData.DrawHandler = { (context: CGContext) in
            let width = context.width
            let height = context.height
            context.setFillColor(Color(repeating: 1.0).cgColor)
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }

        do {
            let element = texture.addElement(size: .init(width: 1, height: 1), handler: drawHandler)
            #expect(
                element.texCoords
                    == .init(origin: .init(x: 2, y: 2), size: .init(width: 1, height: 1)))
        }

        do {
            let element = texture.addElement(size: .init(width: 1, height: 1), handler: drawHandler)
            #expect(
                element.texCoords
                    == .init(origin: .init(x: 5, y: 2), size: .init(width: 1, height: 1)))
        }

        do {
            let element = texture.addElement(size: .init(width: 1, height: 1), handler: drawHandler)
            #expect(
                element.texCoords
                    == .init(origin: .init(x: 2, y: 5), size: .init(width: 1, height: 1)))
        }
    }

    @Test(.enabled(if: isMetalSystemAvailable))
    func removeElement() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))
        let provider = ScaleFactorProviderStub(scaleFactor: 1.0)

        let texture = Texture(pointSize: .init(width: 8, height: 8), scaleFactorProvider: provider)

        let called: Atomic<Bool> = .init(false)

        let element = texture.addElement(size: .init(width: 1, height: 1)) { _ in
            called.store(true, ordering: .relaxed)
        }

        texture.removeElement(element)

        try texture.prepareForRendering(system: system)

        let isCalled = called.load(ordering: .relaxed)

        #expect(!isCalled)
    }

    @Test(.enabled(if: isMetalSystemAvailable))
    func observeElementTexCoords() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))
        let provider = ScaleFactorProviderStub(scaleFactor: 1.0)

        let texture = Texture(pointSize: .init(width: 8, height: 8), scaleFactorProvider: provider)

        let element = texture.addElement(size: .init(width: 1, height: 1)) { _ in }

        var called = false

        let canceller = element.$texCoords.dropFirst().sink { _ in
            called = true
        }

        #expect(!called)
        #expect(element.texCoords == .zero)

        try texture.prepareForRendering(system: system)

        #expect(called)
        #expect(element.texCoords != .zero)

        called = false
        element.texCoords = .zero

        texture.scaleFactor = 2.0
        try texture.prepareForRendering(system: system)

        #expect(called)
        #expect(element.texCoords != .zero)

        canceller.cancel()
    }

    @Test(.enabled(if: isMetalSystemAvailable))
    func observeMetalTexureDidChange() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))
        let provider = ScaleFactorProviderStub(scaleFactor: 1.0)

        let texture = Texture(pointSize: .init(width: 8, height: 8), scaleFactorProvider: provider)

        var calledCount: Int = 0

        let canceller = texture.metalTextureDidChange.sink { _ in
            calledCount += 1
        }

        try texture.prepareForRendering(system: system)

        #expect(calledCount == 1)

        canceller.cancel()
    }

    @Test func observeSizeDidUpdate() throws {
        let provider = ScaleFactorProviderStub(scaleFactor: 2.0)
        let texture = Texture(pointSize: .init(width: 8, height: 8), scaleFactorProvider: provider)

        var calledCount = 0

        let canceller = texture.sizeDidUpdate.sink { _ in
            calledCount += 1
        }

        texture.pointSize = .init(width: 16, height: 16)

        #expect(calledCount == 1)

        canceller.cancel()
    }
}
