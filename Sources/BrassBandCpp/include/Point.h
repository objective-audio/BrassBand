#pragma once

#include <simd/simd.h>

struct PointCpp final {
    simd_float2 simd2;
};

static bool operator==(PointCpp const &lhs, PointCpp const &rhs) {
    return simd_equal(lhs.simd2, rhs.simd2);
}
