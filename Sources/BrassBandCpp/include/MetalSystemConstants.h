#pragma once

#include "Uniforms2d.h"
#include <algorithm>

static size_t constexpr uniformsBufferAllocatingUnit = 1024 * 16;

#if (TARGET_OS_IPHONE && TARGET_OS_EMBEDDED)
static size_t constexpr uniforms2dRequiredAlign = 4;
#else
static size_t constexpr uniforms2dRequiredAlign = 256;
#endif

size_t constexpr calcUniforms2dSize() {
    size_t const requiredAlign = std::max(uniforms2dRequiredAlign, _Alignof(Uniforms2d));
    size_t constexpr size = sizeof(Uniforms2d);
    size_t const mod = size % requiredAlign;
    if (mod > 0) {
        return size - mod + requiredAlign;
    } else {
        return size;
    }
}

size_t constexpr uniforms2dSize = calcUniforms2dSize();
