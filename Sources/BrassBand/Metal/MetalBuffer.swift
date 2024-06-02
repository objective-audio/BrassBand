import Foundation

@MainActor
final class MetalBuffer {
    let mtl: any MTLBuffer

    convenience init?(device: any MTLDevice, length: Int) {
        guard length > 0, let buffer = device.makeBuffer(length: length) else {
            return nil
        }

        self.init(mtl: buffer)
    }

    init(mtl: any MTLBuffer) {
        self.mtl = mtl
    }

    func write<DataType: MeshDataElement>(
        from data: UnsafeBufferPointer<DataType>, dynamicBufferIndex: Int
    ) {
        let capacity = mtl.length / MemoryLayout<DataType>.size

        guard capacity > 0 else {
            assertionFailure()
            return
        }

        let contents = mtl.contents().bindMemory(
            to: DataType.self, capacity: capacity)
        let advancedContents = contents.advanced(by: data.count * dynamicBufferIndex)

        advancedContents.update(from: data.baseAddress!, count: data.count)
    }

    func write(from data: UnsafeRawBufferPointer, dynamicBufferIndex: Int) {
        let source = data.bindMemory(to: Int8.self)
        let destination = mtl.contents().bindMemory(to: Int8.self, capacity: mtl.length)
        let advancedDestination = destination.advanced(by: data.count * dynamicBufferIndex)

        advancedDestination.update(from: source.baseAddress!, count: data.count)
    }
}
