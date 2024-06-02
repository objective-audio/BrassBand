#pragma once

#include "Vertex2d.h"

static bool operator==(Vertex2d const &lhs, Vertex2d const &rhs) {
    return simd_equal(lhs.position, rhs.position) && simd_equal(lhs.texCoord, rhs.texCoord) &&
           simd_equal(lhs.color, rhs.color);
}
