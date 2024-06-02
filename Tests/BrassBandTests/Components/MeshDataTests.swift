import Testing

@testable import BrassBand

@MainActor
struct MeshDataTests {
    @Test func initial() {
        let data = MeshData<Int>(capacity: 2, count: 0, dynamicBufferCount: 1)

        #expect(data.capacity == 2)
        #expect(data.count == 0)
    }

    @Test func count() {
        let data = MeshData<Int>(capacity: 2, count: 0, dynamicBufferCount: 1)

        data.count = 1

        #expect(data.count == 1)

        data.count = 2

        #expect(data.count == 2)

        data.count = 0

        #expect(data.count == 0)
    }

    @Test func access() {
        let data = MeshData<Int>(capacity: 2, count: 0, dynamicBufferCount: 1)

        data.write {
            $0[0] = 100
            $0[1] = 200
        }

        data.read {
            #expect($0[0] == 100)
            #expect($0[1] == 200)
        }
    }

    @Test func byteOffsetWithOneBuffer() {
        let data = MeshData<Int>(capacity: 2, count: 0, dynamicBufferCount: 1)

        #expect(data.byteOffset == 0)
    }
    @Test func byteOffsetWithManyBuffer() {
        let data = MeshData<Int>(capacity: 2, count: 1, dynamicBufferCount: 3)

        // 初期値は最後の位置

        #expect(data.byteOffset == 2 * 2 * MemoryLayout<Int>.size)

        // 何も書き込まずに更新しても位置は動かない

        data.updateRenderBuffer()

        #expect(data.byteOffset == 2 * 2 * MemoryLayout<Int>.size)

        // 書き込みしてから更新したら位置が進む

        data.write { (_: UnsafeMutableBufferPointer<Int>) in }
        data.updateRenderBuffer()

        #expect(data.byteOffset == 0)
    }

    @Test func fetchUpdates() {
        let data = MeshData<Int>(capacity: 2, count: 0, dynamicBufferCount: 1)

        var fetching: MeshDataUpdateReason = []

        data.fetchUpdates(&fetching)

        #expect(fetching.isEmpty)

        data.write { (_: UnsafeMutableBufferPointer<Int>) in }
        data.fetchUpdates(&fetching)

        #expect(fetching == [.dataContent, .renderBuffer])

        fetching = []
        data.updateRenderBuffer()
        data.fetchUpdates(&fetching)

        #expect(fetching == [.dataContent])

        fetching = []
        data.clearUpdates()
        data.fetchUpdates(&fetching)

        #expect(fetching.isEmpty)
    }
}
