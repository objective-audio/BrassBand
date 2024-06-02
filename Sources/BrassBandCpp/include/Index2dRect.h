#pragma once

#include "Index2d.h"

struct Index2dRect final {
    static std::size_t constexpr indexCount = 6;

    Index2d indices[indexCount];
};

static bool operator==(Index2dRect const &lhs, Index2dRect const &rhs) {
    return lhs.indices[0] == rhs.indices[0] && lhs.indices[1] == rhs.indices[1]
        && lhs.indices[2] == rhs.indices[2] && lhs.indices[3] == rhs.indices[3]
    && lhs.indices[4] == rhs.indices[4] && lhs.indices[5] == rhs.indices[5];
}
