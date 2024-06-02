import Foundation

protocol CommandBuffer {}

struct MetalCommandBuffer: CommandBuffer {
    let value: any MTLCommandBuffer
}
