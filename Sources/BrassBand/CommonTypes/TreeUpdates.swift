import Foundation

struct BackgroundUpdateReason: OptionSet {
    let rawValue: Int

    static let color = Self(rawValue: 1 << 0)

    static let all: Self = [.color]
}

struct NodeUpdateReason: OptionSet {
    let rawValue: Int

    static let geometry = Self(rawValue: 1 << 0)
    static let mesh = Self(rawValue: 1 << 1)
    static let collider = Self(rawValue: 1 << 2)
    static let enabled = Self(rawValue: 1 << 3)
    static let hierarchy = Self(rawValue: 1 << 4)
}

struct MeshUpdateReason: OptionSet {
    let rawValue: Int

    static let vertexData = Self(rawValue: 1 << 0)
    static let indexData = Self(rawValue: 1 << 1)
    static let texture = Self(rawValue: 1 << 2)
    static let primitiveType = Self(rawValue: 1 << 3)
    static let color = Self(rawValue: 1 << 4)
    static let meshColorUsed = Self(rawValue: 1 << 5)
    static let matrix = Self(rawValue: 1 << 6)

    static let all: Self = [
        .vertexData, .indexData, .texture, .primitiveType, .color, .meshColorUsed, .matrix,
    ]
}

public struct MeshDataUpdateReason: OptionSet, Sendable {
    public let rawValue: Int

    public static let dataContent = Self(rawValue: 1 << 0)
    public static let dataCount = Self(rawValue: 1 << 1)
    public static let renderBuffer = Self(rawValue: 1 << 2)

    public static let all: Self = [.dataContent, .dataCount, .renderBuffer]

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct RenderTargetUpdateReason: OptionSet, Sendable {
    public let rawValue: Int

    public static let region = Self(rawValue: 1 << 0)
    public static let scaleFactor = Self(rawValue: 1 << 1)
    public static let effect = Self(rawValue: 1 << 2)

    public static let all: Self = [.region, .scaleFactor, .effect]
    public static let sizeUpdated: Self = [.region, .scaleFactor]

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct EffectUpdateReason: OptionSet, Sendable, Equatable {
    public let rawValue: Int

    public static let textures = Self(rawValue: 1 << 0)
    public static let encodable = Self(rawValue: 1 << 1)

    public static let all: Self = [.textures, .encodable]

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

enum BatchBuildingKind: Sendable {
    case rebuild
    case override
}

public struct TreeUpdates {
    var nodeUpdates: NodeUpdateReason = []
    var meshUpdates: MeshUpdateReason = []
    var vertexDataUpdates: MeshDataUpdateReason = []
    var indexDataUpdates: MeshDataUpdateReason = []
    var backgroundUpdates: BackgroundUpdateReason = []
    var renderTargetUpdates: RenderTargetUpdateReason = []
    var effectUpdates: EffectUpdateReason = []

    var isAnyUpdated: Bool {
        !nodeUpdates.isEmpty || !meshUpdates.isEmpty
            || !vertexDataUpdates.isEmpty
            || !indexDataUpdates.isEmpty || !backgroundUpdates.isEmpty
            || !renderTargetUpdates.isEmpty || !effectUpdates.isEmpty
    }

    var isColliderUpdated: Bool {
        return nodeUpdates.andTest([.enabled, .hierarchy, .collider])
    }

    var batchBuildingKind: BatchBuildingKind? {
        if nodeUpdates.andTest([.enabled, .mesh, .hierarchy])
            || meshUpdates.andTest([.texture, .vertexData, .indexData, .primitiveType])
            || vertexDataUpdates.andTest([.dataCount])
            || indexDataUpdates.andTest([.dataCount])
        {
            return .rebuild
        }

        if !nodeUpdates.isEmpty || !meshUpdates.isEmpty
            || !vertexDataUpdates.isEmpty
            || !indexDataUpdates.isEmpty
        {
            return .override
        }

        return nil
    }
}
