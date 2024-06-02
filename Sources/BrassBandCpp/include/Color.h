#pragma once

#include <simd/simd.h>

struct Color final {
    simd_float4 simd4;
};

static bool operator==(Color const &lhs, Color const &rhs) {
    return simd_equal(lhs.simd4, rhs.simd4);
}
