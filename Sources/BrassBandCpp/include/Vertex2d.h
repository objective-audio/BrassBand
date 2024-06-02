#pragma once

#include <simd/simd.h>

struct Vertex2d final {
    simd_float2 position = 0.0f;
    simd_float2 texCoord = 0.0f;
    simd_float4 color = 1.0f;
};
