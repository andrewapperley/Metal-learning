//
//  Test.metal
//  AppCraft
//
//  Created by Andrew Apperley on 2020-07-12.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#import "Common.h"

constant bool hasColourTexture [[function_constant(BaseColourTexture)]];
constant bool hasNormalTexture [[function_constant(NormalTexture)]];
constant bool hasSpecularTexture [[function_constant(SpecularTexture)]];

struct VertexIn {
    float4 position [[attribute(Position)]];
    float3 normal [[attribute(Normal)]];
    float2 uv [[attribute(UV)]];
    float3 tangent [[attribute(Tangent)]];
    float3 bitangent [[attribute(Bitangent)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
    float2 uv;
    float3 worldTangent;
    float3 worldBitangent;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]])
{
  VertexOut out {
    .position = uniforms.projectionMatrix * uniforms.viewMatrix
    * uniforms.modelMatrix * vertexIn.position,
    .worldPosition = (uniforms.modelMatrix * vertexIn.position).xyz,
    .worldNormal = uniforms.normalMatrix * vertexIn.normal,
    .uv = vertexIn.uv,
    .worldTangent = uniforms.normalMatrix * vertexIn.tangent,
    .worldBitangent = uniforms.normalMatrix * vertexIn.bitangent
  };
  return out;
}

fragment float4 fragment_main(
                              VertexOut in [[stage_in]],
                              texture2d<float> baseColourTexture [[texture(BaseColourTexture), function_constant(hasColourTexture)]],
                              texture2d<float> normalTexture [[texture(NormalTexture), function_constant(hasNormalTexture)]],
                              constant Light *lights [[buffer(BufferIndexLights)]],
                              constant FragmentUniforms &fragmentUniforms [[buffer(BufferIndexFragmentUniforms)]]) {
    constexpr sampler textureSampler;
    
    float3 baseColour;
    if (hasColourTexture) {
        baseColour = baseColourTexture.sample(textureSampler, in.uv).rgb;
    } else {
        baseColour = float3(1, 1, 1);
    }
    
    return float4(baseColour, 1);
    
    float3 normal;
    if (hasNormalTexture) {
        normal = normalTexture.sample(textureSampler, in.uv).rgb;
        normal = normal * 2 -1;
    } else {
        normal = in.worldNormal;
    }
    
    float3 diffuseColour = 0;
    float3 ambientColour = 0;
    float3 specularColour = 0;
    float materialShininess = 32;
    float3 materialSpecularColour = float3(1, 1, 1);
    float3 normalDirection = float3x3(in.worldTangent,
                                      in.worldBitangent,
                                      in.worldNormal) * normal;
    normalDirection = normalize(normalDirection);

    for (uint i = 0; i < fragmentUniforms.lightCount; i++) {
        Light light = lights[i];
        switch (light.type) {
            case Sunlight: {
                float3 lightDirection = normalize(-light.position);
                float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
                
                if (diffuseIntensity > 0) {
                    float3 reflection = reflect(lightDirection, normalDirection);
                    float3 cameraDirection = normalize(in.worldPosition - fragmentUniforms.cameraPosition);
                    float specularIntensity = pow(saturate(-dot(reflection, cameraDirection)), materialShininess);
                    specularColour += light.specularColour * materialSpecularColour * specularIntensity;
                }
                
                diffuseColour += light.colour * baseColour * diffuseIntensity;
                break;
            }
            case Spotlight: {
                float d = distance(light.position, in.worldPosition);
                float3 lightDirection = normalize(in.worldPosition - light.position);
                float3 coneDirection = normalize(light.coneDirection);
                float spotResult = dot(lightDirection, coneDirection);
                
                if (spotResult > cos(light.coneAngle)) {
                    float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
                    attenuation *= pow(spotResult, light.coneAttenuation);
                    float diffuseIntensity = saturate(dot(-lightDirection, normalDirection));
                    float3 colour = light.colour * baseColour * diffuseIntensity;
                    colour *= attenuation;
                    diffuseColour += colour;
                }
                break;
            }
            case Pointlight: {
                float d = distance(light.position, in.worldPosition);
                float3 lightDirection = normalize(in.worldPosition - light.position);
                float attenuation = 1.0 / (light.attenuation.x = light.attenuation.y  * d + light.attenuation.z * d * d);
                float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
                float3 colour = light.colour * baseColour * diffuseIntensity;
                colour *= attenuation;
                diffuseColour += colour;
                break;
            }
            case Ambientlight: {
                ambientColour += light.colour * light.intensity;
                break;
            }
        }
    }
    return float4(diffuseColour + ambientColour + specularColour, 1);
}
