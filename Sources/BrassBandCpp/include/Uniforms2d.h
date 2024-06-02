#pragma once

#include <simd/simd.h>

struct Uniforms2d final {
    simd_float4x4 matrix;
    simd_float4 color = 1.0f;
    bool isMeshColorUsed = false;
};
