import Foundation
import Metal

var isMetalSystemAvailable: Bool { MTLCreateSystemDefaultDevice() != nil }
