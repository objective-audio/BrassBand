import Testing

@testable import BrassBand

struct TreeUpdatesTest {
    @Test func isAnyUpdated() {
        #expect(TreeUpdates(nodeUpdates: .geometry).isAnyUpdated)
        #expect(TreeUpdates(nodeUpdates: .collider).isAnyUpdated)
        #expect(TreeUpdates(meshUpdates: .vertexData).isAnyUpdated)
        #expect(TreeUpdates(vertexDataUpdates: .dataContent).isAnyUpdated)
        #expect(TreeUpdates(indexDataUpdates: .dataContent).isAnyUpdated)
        #expect(TreeUpdates(backgroundUpdates: .color).isAnyUpdated)

        #expect(!TreeUpdates().isAnyUpdated)
    }

    @Test func isColliderUpdated() {
        #expect(TreeUpdates(nodeUpdates: .collider).isColliderUpdated)
        #expect(TreeUpdates(nodeUpdates: .enabled).isColliderUpdated)
        #expect(TreeUpdates(nodeUpdates: .hierarchy).isColliderUpdated)

        #expect(!TreeUpdates(nodeUpdates: .geometry).isColliderUpdated)
        #expect(!TreeUpdates(nodeUpdates: .mesh).isColliderUpdated)

        #expect(!TreeUpdates(meshUpdates: .vertexData).isColliderUpdated)
        #expect(!TreeUpdates(vertexDataUpdates: .dataContent).isColliderUpdated)
        #expect(!TreeUpdates(indexDataUpdates: .dataContent).isColliderUpdated)
        #expect(!TreeUpdates(backgroundUpdates: .color).isColliderUpdated)

        #expect(!TreeUpdates().isColliderUpdated)
    }

    @Test func batchBuildingKind() {
        #expect(TreeUpdates().batchBuildingKind == nil)

        #expect(TreeUpdates(nodeUpdates: .enabled).batchBuildingKind == .rebuild)
        #expect(TreeUpdates(nodeUpdates: .mesh).batchBuildingKind == .rebuild)
        #expect(TreeUpdates(nodeUpdates: .hierarchy).batchBuildingKind == .rebuild)
        #expect(TreeUpdates(meshUpdates: .texture).batchBuildingKind == .rebuild)
        #expect(TreeUpdates(meshUpdates: .vertexData).batchBuildingKind == .rebuild)
        #expect(TreeUpdates(meshUpdates: .indexData).batchBuildingKind == .rebuild)
        #expect(TreeUpdates(meshUpdates: .primitiveType).batchBuildingKind == .rebuild)
        #expect(TreeUpdates(vertexDataUpdates: .dataCount).batchBuildingKind == .rebuild)
        #expect(TreeUpdates(indexDataUpdates: .dataCount).batchBuildingKind == .rebuild)

        #expect(
            TreeUpdates(
                nodeUpdates: [.geometry, .collider],
                meshUpdates: [.color, .meshColorUsed, .matrix],
                vertexDataUpdates: [.dataContent, .renderBuffer],
                indexDataUpdates: [.dataContent, .renderBuffer]
            ).batchBuildingKind == .override)
    }
}
