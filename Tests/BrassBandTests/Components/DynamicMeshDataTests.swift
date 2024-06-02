import Testing

@testable import BrassBand

extension Int: MeshDataElement {}

@MainActor
struct DynamicMeshDataTests {
    @Test func initWithoutCount() {
        let data = DynamicMeshData<Int>(capacity: 2)

        let rawMeshData = data.rawMeshData
        #expect(rawMeshData.count == 2)
        #expect(rawMeshData.capacity == 2)
    }

    @Test func initWithCount() {
        let data = DynamicMeshData<Int>(capacity: 2, count: 0)

        let rawMeshData = data.rawMeshData
        #expect(rawMeshData.count == 0)
        #expect(rawMeshData.capacity == 2)
    }

    @Test func write() {
        let data = DynamicMeshData<Int>(capacity: 2)

        data.write {
            $0[0] = 100
            $0[1] = 200
        }

        data.rawMeshData.read {
            #expect($0[0] == 100)
            #expect($0[1] == 200)
        }
    }

    @Test func writeAsync() async {
        let data = DynamicMeshData<Int>(capacity: 2)

        await data.writeAsync {
            $0[0] = 300
            $0[1] = 400
        }

        data.rawMeshData.read {
            #expect($0[0] == 300)
            #expect($0[1] == 400)
        }
    }
}
