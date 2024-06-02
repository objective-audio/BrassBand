#include <simd/simd.h>
#include <metal_stdlib>
#include "Vertex2d.h"
#include "Uniforms2d.h"

using namespace metal;

struct ColorInout2d {
    float4 position[[position]];
    float4 color;
    float2 texCoord[[user(texturecoord)]];
};

struct Inputs {
    texture2d<float> tex2D;
    sampler sampler2D;
};

vertex ColorInout2d vertex2d(device Vertex2d const *vertex_array[[buffer(0)]],
                              constant Uniforms2d &uniforms[[buffer(1)]], unsigned int vid[[vertex_id]]) {
    ColorInout2d out;

    out.position = uniforms.matrix * float4(float2(vertex_array[vid].position), 0.0, 1.0);
    out.color = uniforms.isMeshColorUsed ? vertex_array[vid].color * uniforms.color : uniforms.color;
    out.texCoord = vertex_array[vid].texCoord;

    return out;
}

fragment float4 fragment2d_with_texture(ColorInout2d in[[stage_in]], constant Inputs &inputs[[buffer(0)]]) {
    return inputs.tex2D.sample(inputs.sampler2D, in.texCoord) * in.color * float4(float3(in.color.a), 1.0);
}

fragment float4 fragment2d_without_texture(ColorInout2d in[[stage_in]]) {
    return in.color * float4(float3(in.color.a), 1.0);
}
