import Foundation

public func justify(begin: Float, end: Float, ratios: [Float]) -> [Float] {
    var outValues: [Float] = []
    outValues.reserveCapacity(ratios.count + 1)

    var sum: Float = 0.0
    let total: Float = ratios.reduce(0.0, +)
    let distance = end - begin

    for index in 0..<(ratios.count + 1) {
        if index == 0 {
            if ratios.count == 0 {
                outValues.append(begin + distance * 0.5)
            } else {
                outValues.append(begin)
            }
        } else {
            sum += ratios[index - 1]
            outValues.append(begin + distance * (sum / total))
        }
    }

    return outValues
}
