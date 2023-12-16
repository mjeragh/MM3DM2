/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

#include <metal_stdlib>
using namespace metal;

#import "Common.h"

constant float pi = 3.1415926535897932384626433832795;

#import "Vertex.h"

// functions
float3 computeSpecular(
  float3 normal,
  float3 viewDirection,
  float3 lightDirection,
  float roughness,
  float3 F0);

float3 computeDiffuse(
  Material material,
  float3 normal,
  float3 lightDirection);

///https://github.com/Nadrin/PBR/blob/master/data/shaders/glsl/pbr_fs.glsl

fragment float4 fragment_PBR(
                             VertexOut in [[stage_in]],
                             constant Params &params [[buffer(ParamsBuffer)]],
                             constant Light *lights [[buffer(LightBuffer)]],
                             constant Material &_material [[buffer(MaterialBuffer)]],
                             depth2d<float> shadowTexture [[texture(15)]])
{
 
  
  Material material = _material;

  // extract color
 
    material.baseColor = _material.baseColor;
  // extract metallic
    material.metallic = _material.metallic;
  // extract roughness
    material.roughness = _material.roughness;
  // extract ambient occlusion
    material.ambientOcclusion = _material.ambientOcclusion;

  // normal map
  float3 normal;
  normal = in.worldNormal;
  
  normal = normalize(normal);
  
  float3 viewDirection = normalize(params.cameraPosition);
    
    float3 specularColor = 0;
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    
    for (uint i = 0; i < params.lightCount; i++) { //from debugging this only for sun lights
      Light light = lights[i];
        switch (light.type) {
          case Sun: {
              float3 lightDirection = normalize(light.position);
              float3 F0 = mix(0.04, material.baseColor, material.metallic);
            
              specularColor +=
                saturate(computeSpecular(
                  normal,
                  viewDirection,
                  lightDirection,
                  material.roughness,
                  F0));

              diffuseColor +=
                saturate(computeDiffuse(
                  material,
                  normal,
                  lightDirection) * light.color);
            break;
          }
          case Dot: {
            //accumulatedLighting += calculatePoint(light, position, normal, material);
            break;
          }
          case Spot: {
            //accumulatedLighting += calculateSpot(light, position, normal, material);
            break;
          }
          case Ambient: {
              ///https://learnopengl.com/PBR/Lighting
              ///There is much more
              float3  ambient = float3(0.03) * material.baseColor * material.ambientOcclusion;
                        ambientColor = ambient;
            break;
          }
          case unused: {
            break;
          }
        }
      
    }
    // shadow calculation
    
    float3 shadowPosition = in.shadowPosition.xyz / in.shadowPosition.w;
    
    float2 xy = shadowPosition.xy;
    xy = xy * 0.5 + 0.5;
    xy.y = 1 - xy.y;
//
//    if (xy.x < 0.0 || xy.x > 1.0 || xy.y < 0.0 || xy.y > 1.0) {
//      return float4(1, 0, 0, 1);
//    }
    
    xy = saturate(xy);
    
    constexpr sampler s(
                        coord::normalized,
                        filter::linear,
                        address::clamp_to_edge,
                        compare_func:: less);
    
    float shadow_sample = shadowTexture.sample(s, xy);
    
    if (shadowPosition.z > shadow_sample + 0.001){
        diffuseColor *= 0.5;
    }

    
    return float4(diffuseColor + specularColor + ambientColor, 1);//float4(diffuseColor + specularColor, 1);
}

float G1V(float nDotV, float k)
{
  return 1.0f / (nDotV * (1.0f - k) + k);
}

// specular optimized-ggx
// AUTHOR John Hable. Released into the public domain
float3 computeSpecular(
    float3 normal,
    float3 viewDirection,
    float3 lightDirection,
    float roughness,
    float3 F0) {
  float alpha = roughness * roughness;
  float3 halfVector = normalize(viewDirection + lightDirection);
  float nDotL = saturate(dot(normal, lightDirection));
  float nDotV = saturate(dot(normal, viewDirection));
  float nDotH = saturate(dot(normal, halfVector));
  float lDotH = saturate(dot(lightDirection, halfVector));
  
  float3 F;
  float D, vis;
  
  // Distribution
  float alphaSqr = alpha * alpha;
  float pi = 3.14159f;
  float denom = nDotH * nDotH * (alphaSqr - 1.0) + 1.0f;
  D = alphaSqr / (pi * denom * denom);

  // Fresnel
  float lDotH5 = pow(1.0 - lDotH, 5);
  F = F0 + (1.0 - F0) * lDotH5;
  
  // V
  float k = alpha / 2.0f;
  vis = G1V(nDotL, k) * G1V(nDotV, k);
  
  float3 specular = nDotL * D * F * vis;
  return specular;
}

// diffuse
float3 computeDiffuse(
  Material material,
  float3 normal,
  float3 lightDirection)
{
  float nDotL = saturate(dot(normal, lightDirection));
  float3 diffuse = float3(((1.0/pi) * material.baseColor) * (1.0 - material.metallic));
  diffuse = float3(material.baseColor) * (1.0 - material.metallic);
  return diffuse * nDotL * material.ambientOcclusion;
}
