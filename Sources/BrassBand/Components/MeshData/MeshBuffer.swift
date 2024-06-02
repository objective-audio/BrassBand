import Foundation

@MainActor
final class MeshBuffer<Element: MeshDataElement> {
    private var data: Data
    private let writeBuffer: WriteBuffer<Element>

    var rawValue: UnsafeRawBufferPointer {
        data.withUnsafeBytes { $0 }
    }

    init(capacity: Int) {
        let size = capacity * MemoryLayout<Element>.stride
        self.data = Data(count: size)
        self.writeBuffer = WriteBuffer<Element>(capacity: capacity)
    }

    func read(
        _ handler: @MainActor (UnsafeBufferPointer<Element>) -> Void
    ) {
        data.withUnsafeBytes { bytes in
            handler(bytes.bindMemory(to: Element.self))
        }
    }

    func write(
        _ handler: @MainActor (UnsafeMutableBufferPointer<Element>) -> Void
    ) {
        data.withUnsafeMutableBytes { bytes in
            handler(bytes.bindMemory(to: Element.self))
        }
    }

    func writeAsync(
        _ handler: @Sendable @escaping (UnsafeMutableBufferPointer<Element>) -> Void
    ) async {
        // 書き込みバッファに書き込み
        let newData = await writeBuffer.writeAndCreateNewData(handler)

        // MainActorでデータを入れ替え
        self.data = newData
    }
}

private actor WriteBuffer<Element: MeshDataElement> {
    private var buffer: Data

    init(capacity: Int) {
        self.buffer = Data(count: capacity * MemoryLayout<Element>.stride)
    }

    func writeAndCreateNewData(_ handler: @Sendable (UnsafeMutableBufferPointer<Element>) -> Void)
        -> Data
    {
        buffer.withUnsafeMutableBytes { bytes in
            handler(bytes.bindMemory(to: Element.self))
        }
        // 新しいDataを作成してコピー
        var newData = Data(count: buffer.count)
        newData.withUnsafeMutableBytes { destBytes in
            buffer.withUnsafeBytes { srcBytes in
                destBytes.copyMemory(from: srcBytes)
            }
        }
        return newData
    }
}
