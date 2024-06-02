import Foundation

@MainActor
public final class MeshData<Element: MeshDataElement> {
    enum Error: Swift.Error {
        case invalidSystem
    }

    var count: Int {
        willSet { precondition(newValue <= capacity) }
        didSet { updates.insert(.dataCount) }
    }

    let capacity: Int
    private(set) var metalBuffer: MetalBuffer?

    private let buffer: MeshBuffer<Element>
    private let byteCapacity: Int
    private var updates: MeshDataUpdateReason = []
    private let dynamicBufferCount: Int
    private var dynamicBufferIndex: Int

    private weak var metalSystem: (any MeshDataMetalSystem)?

    public init(
        capacity: Int, count: Int? = nil, dynamicBufferCount: Int
    ) {
        precondition(capacity > 0)
        precondition(dynamicBufferCount > 0)
        if let count {
            precondition(count >= 0 && count <= capacity)
        }

        self.buffer = .init(capacity: capacity)
        self.count = count ?? capacity
        self.capacity = capacity
        self.byteCapacity = capacity * MemoryLayout<Element>.size
        self.dynamicBufferCount = dynamicBufferCount
        self.dynamicBufferIndex = dynamicBufferCount - 1
    }

    public func read(
        _ handler: @MainActor (UnsafeBufferPointer<Element>) -> Void
    ) {
        buffer.read(handler)
    }

    public func write(
        _ handler: @MainActor (UnsafeMutableBufferPointer<Element>) -> Void
    ) {
        buffer.write(handler)

        updates.formUnion([.dataContent, .renderBuffer])
    }

    public func writeAsync(
        _ handler: @Sendable @escaping (UnsafeMutableBufferPointer<Element>) -> Void
    ) async {
        await buffer.writeAsync(handler)

        updates.formUnion([.dataContent, .renderBuffer])
    }
}

extension MeshData {
    var byteOffset: Int {
        dynamicBufferIndex * byteCapacity
    }

    func fetchUpdates(_ ioUpdates: inout MeshDataUpdateReason) {
        ioUpdates.formUnion(updates)
    }

    func prepareForRendering(system: some RenderSystem) throws {
        if let system = system as? any MeshDataMetalSystem {
            if metalSystem !== system {
                metalSystem = system
                metalBuffer = nil
            }

            if metalBuffer == nil {
                let vertexLength = byteCapacity * dynamicBufferCount
                metalBuffer = try system.makeMetalBuffer(length: vertexLength)
            }
        } else {
            throw Error.invalidSystem
        }
    }

    func updateRenderBuffer() {
        guard updates.contains(.renderBuffer) else { return }

        dynamicBufferIndex = (dynamicBufferIndex + 1) % dynamicBufferCount

        metalBuffer?.write(from: buffer.rawValue, dynamicBufferIndex: dynamicBufferIndex)

        updates.remove(.renderBuffer)
    }

    func clearUpdates() {
        updates = []
    }
}

@MainActor
protocol MeshDataMetalSystem: AnyObject, RenderSystem {
    func makeMetalBuffer(length: Int) throws -> MetalBuffer
}

extension MetalSystem: MeshDataMetalSystem {}
