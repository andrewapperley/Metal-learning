//
//  Common.h
//  AppCraft
//
//  Created by Andrew Apperley on 2020-07-12.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

#ifndef Common_h
#define Common_h
#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef struct {
    uint lightCount;
    vector_float3 cameraPosition;
} FragmentUniforms;

typedef enum {
    Position = 0,
    Normal = 1,
    UV = 2,
    Tangent = 3,
    Bitangent = 4
} Attributes;

typedef enum {
    BaseColourTexture = 0,
    NormalTexture = 1,
    SpecularTexture = 2
} Textures;

typedef enum {
  BufferIndexVertices = 0,
  BufferIndexUniforms = 11,
  BufferIndexLights = 12,
  BufferIndexFragmentUniforms = 13
} BufferIndices;

typedef enum {
    Sunlight = 0,
    Spotlight = 1,
    Pointlight = 2,
    Ambientlight = 3
} LightType;

typedef struct {
    vector_float3 position;
    vector_float3 colour;
    vector_float3 specularColour;
    float intensity;
    vector_float3 attenuation;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
    LightType type;
} Light;

#endif /* Common_h */
