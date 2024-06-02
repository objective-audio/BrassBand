import Testing

@testable import BrassBand

@MainActor
struct StaticMeshDataTests {
    @Test func initialize() {
        let data = StaticMeshData<Int>(count: 2) {
            $0[0] = 100
            $0[1] = 200
        }

        data.rawMeshData.read {
            #expect($0[0] == 100)
            #expect($0[1] == 200)
        }
    }

    @Test func initializeAsync() async {
        let data = await StaticMeshData<Int>(count: 2) { buffer in
            buffer[0] = 100
            buffer[1] = 200
        }

        data.rawMeshData.read {
            #expect($0[0] == 100)
            #expect($0[1] == 200)
        }
    }
}
