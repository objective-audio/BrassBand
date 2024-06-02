import CoreGraphics
import Foundation

@MainActor
public final class Texture {
    public typealias ElementDrawHandler = @Sendable (CGContext) -> Void

    enum Error: Swift.Error {
        case invalidSystem
    }

    var pointSize: UIntSize {
        didSet {
            if pointSize != oldValue {
                sizeUpdated()
            }
        }
    }
    var scaleFactor: Double {
        didSet {
            if scaleFactor != oldValue {
                sizeUpdated()
            }
        }
    }
    var actualSize: UIntSize {
        .init(
            width: UInt32(Double(pointSize.width) * scaleFactor),
            height: UInt32(Double(pointSize.height) * scaleFactor))
    }

    let usage: TextureUsage
    let pixelFormat: PixelFormat

    private weak var metalSystem: (any Texture.MetalSystem)?
    private(set) var metalTexture: (any Texture.MetalTexture)?
    private let drawPadding: UInt32
    private var drawActualPadding: UInt32
    private var drawActualPosition: UIntPoint
    private var textureElements: [TextureElement] = []
    private var maxLineHeight: UInt32 = 0

    private let metalTextureDidChangeSubject: PassthroughSubject<Void, Never> = .init()
    private let sizeDidUpdateSubject: PassthroughSubject<Void, Never> = .init()

    private var cancellables: Set<AnyCancellable> = []

    public init(
        pointSize: UIntSize, drawPadding: UInt32 = 2, usage: TextureUsage = [.shaderRead],
        pixelFormat: PixelFormat = .rgba8Unorm,
        scaleFactorProvider: some Texture.ScaleFactorProviding
    ) {
        self.pointSize = pointSize
        self.scaleFactor = scaleFactorProvider.scaleFactor
        self.usage = usage
        self.pixelFormat = pixelFormat
        self.drawPadding = drawPadding

        drawActualPadding = UInt32(Double(drawPadding) * scaleFactor)
        drawActualPosition = .init(x: drawActualPadding, y: drawActualPadding)

        scaleFactorProvider.scaleFactorPublisher.sink { [weak self] scaleFactor in
            self?.scaleFactor = scaleFactor
        }.store(in: &cancellables)
    }

    public func addElement(size: UIntSize, handler: @escaping ElementDrawHandler) -> TextureElement
    {
        let element = TextureElement(size: size, drawHandler: handler)

        if metalTexture != nil {
            addImageToMetalTexture(element)
        }

        textureElements.append(element)

        return element
    }

    public func removeElement(_ element: TextureElement) {
        textureElements.removeAll { $0 === element }
    }

    public var metalTextureDidChange: AnyPublisher<Void, Never> {
        metalTextureDidChangeSubject.eraseToAnyPublisher()
    }

    public var sizeDidUpdate: AnyPublisher<Void, Never> {
        sizeDidUpdateSubject.eraseToAnyPublisher()
    }
}

extension Texture {
    private func sizeUpdated() {
        metalTexture = nil
        drawActualPadding = UInt32(Double(drawPadding) * scaleFactor)
        drawActualPosition = .init(x: drawActualPadding, y: drawActualPadding)

        sizeDidUpdateSubject.send()
    }

    private func addImagesToMetalTexture() {
        for element in textureElements {
            addImageToMetalTexture(element)
        }
    }

    private func addImageToMetalTexture(_ element: TextureElement) {
        guard metalTexture != nil else {
            fatalError()
        }

        let imageSize = ImageSize(pointSize: element.size, scaleFactor: scaleFactor)

        guard let imageData = ImageData.make(size: imageSize, drawHandler: element.drawHandler),
            let texCoords = reserveImageSize(actualSize: imageSize.actual)
        else {
            return
        }

        element.texCoords = texCoords

        replaceImage(imageData: imageData, origin: texCoords.origin)
    }

    private func reserveImageSize(actualSize: UIntSize) -> UIntRegion? {
        prepareDrawPosition(size: actualSize)

        guard canDraw(size: actualSize) else {
            return nil
        }

        let origin = drawActualPosition

        moveDrawPosition(size: actualSize)

        return .init(origin: origin, size: actualSize)
    }

    @discardableResult
    private func replaceImage(imageData: ImageData, origin: UIntPoint) -> UIntRegion? {
        guard let metalTexture else {
            return nil
        }

        let region = UIntRegion(origin: origin, size: imageData.size.actual)

        metalTexture.replaceData(region: region, data: imageData.data)

        return region
    }

    private func prepareDrawPosition(size: UIntSize) {
        if actualSize.width < (drawActualPosition.x + size.width + drawActualPadding) {
            moveDrawPosition(size: size)
        }
    }

    private func moveDrawPosition(size: UIntSize) {
        drawActualPosition.x += size.width + drawActualPadding

        if actualSize.width < drawActualPosition.x {
            drawActualPosition.y += maxLineHeight + drawActualPadding
            maxLineHeight = 0
            drawActualPosition.x = drawActualPadding
        }

        maxLineHeight = max(maxLineHeight, size.height)
    }

    func canDraw(size: UIntSize) -> Bool {
        let actualSize = self.actualSize

        if (actualSize.width < drawActualPosition.x + size.width + drawActualPadding)
            || (actualSize.height < drawActualPosition.y + size.height + drawActualPadding)
        {
            return false
        }

        return true
    }
}

extension Texture {
    func prepareForRendering(system: some RenderSystem) throws {
        if let system = system as? any Texture.MetalSystem {
            if metalSystem !== system {
                metalSystem = system
                metalTexture = nil
            }

            if metalTexture == nil {
                metalTexture = try system.makeMetalTextureForTexture(
                    actualSize: actualSize, usage: usage, pixelFormat: pixelFormat)

                addImagesToMetalTexture()

                metalTextureDidChangeSubject.send()
            }
        } else {
            throw Error.invalidSystem
        }
    }
}
