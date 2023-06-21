//
//  Shaders.metal
//  MM3DUI
//
//  Created by Mohammad Jeragh on 09/07/2022.
//

#include <metal_stdlib>
#include <simd/simd.h>
#include <metal_atomic>

#import "Lighting.h"
#import "Vertex.h"

using namespace metal;

constant bool hasColorTexture [[function_constant(0)]];
constant bool hasNormalTexture [[function_constant(1)]];
constant bool hasSkeleton [[function_constant(5)]];
constant bool hasInstances [[function_constant(6)]];





[[vertex]] VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                                 constant float4x4 *jointMatrices [[buffer(22), function_constant(hasSkeleton)]],
                                 constant Instances *instances [[buffer(20), function_constant(hasInstances)]],
                                 uint instanceID [[instance_id, function_constant(hasInstances)]],
                             constant Uniforms &uniforms [[buffer(UniformsBuffer)]])
{
    float4 position = vertexIn.position;
    float4 normal = float4(vertexIn.normal,0);
    float4 tangent = float4(vertexIn.tangent,0);
    float4 bitangent = float4(vertexIn.bitangent,0);
   
    if (hasSkeleton){
        float4 weights = vertexIn.weights;
        ushort4 joints = vertexIn.joints;
        position=
            weights.x * (jointMatrices[joints.x] * position) +
            weights.y * (jointMatrices[joints.y] * position) +
            weights.z * (jointMatrices[joints.z] * position) +
            weights.w * (jointMatrices[joints.w] * position);
        normal=
            weights.x * (jointMatrices[joints.x] * normal) +
            weights.y * (jointMatrices[joints.y] * normal) +
            weights.z * (jointMatrices[joints.z] * normal) +
            weights.w * (jointMatrices[joints.w] * normal);
        tangent=
            weights.x * (jointMatrices[joints.x] * tangent) +
            weights.y * (jointMatrices[joints.y] * tangent) +
            weights.z * (jointMatrices[joints.z] * tangent) +
            weights.w * (jointMatrices[joints.w] * tangent);
        bitangent=
            weights.x * (jointMatrices[joints.x] * bitangent) +
            weights.y * (jointMatrices[joints.y] * bitangent) +
            weights.z * (jointMatrices[joints.z] * bitangent) +
            weights.w * (jointMatrices[joints.w] * bitangent);
    }
    VertexOut out;
    if (hasInstances) {
        Instances instance = instances[instanceID];
        out.position = uniforms.projectionMatrix * uniforms.viewMatrix
        * uniforms.modelMatrix * instance.modelMatrix * position;
        out.worldPosition = (uniforms.modelMatrix * instance.modelMatrix * vertexIn.position).xyz;
        out.worldNormal = uniforms.normalMatrix * instance.normalMatrix * normal.xyz;
        out.worldTangent = uniforms.normalMatrix * instance.normalMatrix * tangent.xyz;
        out.worldBitangent = uniforms.normalMatrix * instance.normalMatrix * bitangent.xyz;
        out.uv = vertexIn.uv;
      //    .clip_distance[0] = dot(uniforms.modelMatrix * vertexIn.position, uniforms.clipPlane)
        
    } else {
        
        out.position = uniforms.projectionMatrix * uniforms.viewMatrix
        * uniforms.modelMatrix * position;
        out.worldPosition = (uniforms.modelMatrix * vertexIn.position).xyz;
        out.worldNormal = uniforms.normalMatrix * normal.xyz;
        out.worldTangent = uniforms.normalMatrix * tangent.xyz;
        out.worldBitangent = uniforms.normalMatrix * bitangent.xyz;
        out.uv = vertexIn.uv;
        out.shadowPosition = uniforms.shadowProjectionMatrix * uniforms.shadowViewMatrix * uniforms.modelMatrix * vertexIn.position;
        //    .clip_distance[0] = dot(uniforms.modelMatrix * vertexIn.position, uniforms.clipPlane)
    }
  
  return out;
}


//fragment float4 fragment_main(
//  constant Params &params [[buffer(ParamsBuffer)]],
//  VertexOut in [[stage_in]],
//  texture2d<float> baseColorTexture [[texture(BaseColor)]])
//{
//  constexpr sampler textureSampler(
//    filter::linear,
//    mip_filter::linear,
//    max_anisotropy(8),
//    address::repeat);
//  float3 baseColor = baseColorTexture.sample(
//    textureSampler,
//    in.uv * params.tiling).rgb;
//  return float4(baseColor, 1);
//}



[[fragment]] float4 fragment_main (VertexOut in [[stage_in]],
                                   constant Material &material [[buffer(MaterialBuffer)]],
                                   constant Light *lights [[buffer(LightBuffer)]],
                                   constant Params &params [[buffer(ParamsBuffer)]],
                                   depth2d<float> shadowTexture [[texture(15)]]){
    float3 normalDirection = normalize(in.worldNormal);
    float3 color = phongLighting(normalDirection,
                                 in.worldPosition,
                                 params,
                                 lights,
                                 material);
    
    color *= calculateShadow(in.shadowPosition, shadowTexture);
    
    return float4(color,1);
}



[[fragment]] float4 fragment_normals(VertexOut in [[stage_in]]) {
    return float4(in.worldNormal, 1);

}

[[fragment]] float4 fragment_hemi(VertexOut in [[stage_in]]) {
    float4 sky = float4(0.34,0.9,1.0,1.0);
    float4 earth = float4(0.29,0.58,0.2,1.0);
    float intensity = in.worldNormal.y * 0.5 + 0.5;
    return mix(earth,sky , intensity);

}

