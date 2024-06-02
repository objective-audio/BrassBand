#pragma once

#include <simd/simd.h>

struct RgbColor final {
    simd_float3 simd3;
};

static bool operator==(RgbColor const &lhs, RgbColor const &rhs) {
    return simd_equal(lhs.simd3, rhs.simd3);
}
