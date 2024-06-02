#pragma once

#include "Uniforms2d.h"

static bool operator==(Uniforms2d const &lhs, Uniforms2d const &rhs) {
    return lhs.isMeshColorUsed == rhs.isMeshColorUsed && simd_equal(lhs.color, rhs.color) &&
           simd_equal(lhs.matrix, rhs.matrix);
}
