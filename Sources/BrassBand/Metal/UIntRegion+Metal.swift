import Foundation

extension MTLRegion {
    init(_ region: UIntRegion) {
        self = MTLRegionMake2D(
            Int(region.origin.x), Int(region.origin.y), Int(region.size.width),
            Int(region.size.height))
    }
}
