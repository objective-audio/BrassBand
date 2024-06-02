#pragma once

#include "Vertex2dOperators.h"

struct Vertex2dRect final {
    static std::size_t constexpr vertexCount = 4;

    Vertex2d vertices[vertexCount];
};

static bool operator==(Vertex2dRect const &lhs, Vertex2dRect const &rhs) {
    return lhs.vertices[0] == rhs.vertices[0] && lhs.vertices[1] == rhs.vertices[1]
    && lhs.vertices[2] == rhs.vertices[2] && lhs.vertices[3] == rhs.vertices[3];
}
