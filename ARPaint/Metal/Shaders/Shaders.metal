//
//  Shaders.metal
//  ARMetalTest
//
//  Created by David Crooks on 07/02/2019.
//  Copyright © 2019 David Crooks. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

// Include header shared between this Metal shader code and C code executing Metal API commands
#import "ShaderTypes.h"
#import "Noise.h"

using namespace metal;

typedef struct {
    float3 position [[attribute(kVertexAttributePosition)]];
    float2 texCoord [[attribute(kVertexAttributeTexcoord)]];
    half3 normal    [[attribute(kVertexAttributeNormal)]];
} Vertex;

typedef struct {
    float4 position [[position]];
    float4 color;
    half3  eyePosition;
    half3  normal;
} ColorInOut;

// Anchor geometry vertex function
vertex ColorInOut anchorGeometryVertexTransform(Vertex in [[stage_in]],
                                                constant SharedUniforms &sharedUniforms [[ buffer(kBufferIndexSharedUniforms) ]],
                                                constant InstanceUniforms *instanceUniforms [[ buffer(kBufferIndexInstanceUniforms) ]],
                                                ushort vid [[vertex_id]],
                                                ushort iid [[instance_id]]) {
    ColorInOut out;
    
    // Make position a float4 to perform 4x4 matrix math on it
    float4 position = float4(in.position, 1.0);
    
    float4x4 modelMatrix = instanceUniforms[iid].modelMatrix;
    float4x4 modelViewMatrix = sharedUniforms.viewMatrix * modelMatrix;
    
    // Calculate the position of our vertex in clip space and output for clipping and rasterization
    out.position = sharedUniforms.projectionMatrix * modelViewMatrix * position;
    
    // Color each face a different color
    ushort colorID = vid / 4 % 6;
    out.color = colorID == 0 ? float4(0.0, 1.0, 0.0, 1.0) // Right face
              : colorID == 1 ? float4(1.0, 0.0, 0.0, 1.0) // Left face
              : colorID == 2 ? float4(0.0, 0.0, 1.0, 1.0) // Top face
              : colorID == 3 ? float4(1.0, 0.5, 0.0, 1.0) // Bottom face
              : colorID == 4 ? float4(1.0, 1.0, 0.0, 1.0) // Back face
              : float4(1.0, 1.0, 1.0, 1.0); // Front face
    
    // Calculate the positon of our vertex in eye space
    out.eyePosition = half3((modelViewMatrix * position).xyz);
    
    // Rotate our normals to world coordinates
    float4 normal = modelMatrix * float4(in.normal.x, in.normal.y, in.normal.z, 0.0f);
    out.normal = normalize(half3(normal.xyz));
    
    return out;
}

// Anchor geometry fragment function
fragment float4 anchorGeometryFragmentLighting(ColorInOut in [[stage_in]],
                                               constant SharedUniforms &uniforms [[ buffer(kBufferIndexSharedUniforms) ]]) {
    
    float3 normal = float3(in.normal);
    
    // Calculate the contribution of the directional light as a sum of diffuse and specular terms
    float3 directionalContribution = float3(0);
    {
        // Light falls off based on how closely aligned the surface normal is to the light direction
        float nDotL = saturate(dot(normal, -uniforms.directionalLightDirection));
        
        // The diffuse term is then the product of the light color, the surface material
        // reflectance, and the falloff
        float3 diffuseTerm = uniforms.directionalLightColor * nDotL;
        
        // Apply specular lighting...
        
        // 1) Calculate the halfway vector between the light direction and the direction they eye is looking
        float3 halfwayVector = normalize(-uniforms.directionalLightDirection - float3(in.eyePosition));
        
        // 2) Calculate the reflection angle between our reflection vector and the eye's direction
        float reflectionAngle = saturate(dot(normal, halfwayVector));
        
        // 3) Calculate the specular intensity by multiplying our reflection angle with our object's
        //    shininess
        float specularIntensity = saturate(powr(reflectionAngle, uniforms.materialShininess));
        
        // 4) Obtain the specular term by multiplying the intensity by our light's color
        float3 specularTerm = uniforms.directionalLightColor * specularIntensity;
        
        // Calculate total contribution from this light is the sum of the diffuse and specular values
        directionalContribution = diffuseTerm + specularTerm;
    }
    
    // The ambient contribution, which is an approximation for global, indirect lighting, is
    // the product of the ambient light intensity multiplied by the material's reflectance
    float3 ambientContribution = uniforms.ambientLightColor;
    
    // Now that we have the contributions our light sources in the scene, we sum them together
    // to get the fragment's lighting value
    float3 lightContributions = ambientContribution + directionalContribution;
    
    // We compute the final color by multiplying the sample from our color maps by the fragment's
    // lighting value
    float3 color = in.color.rgb * lightContributions;
    
    // We use the color we just computed and the alpha channel of our
    // colorMap for this fragment's alpha value
    return float4(color, in.color.w);
}

typedef struct {
    float4 position [[attribute(kVertexAttributePosition)]];
    float4 color [[attribute(1)]];
    float size [[attribute(2)]];
    float hardness [[attribute(3)]];
} PointVertex;


typedef struct {
    float4 position [[position]];
    float pointSize [[point_size]];
    float pointSizeInMeters;
    float4 positionInMeters;
    float4 color;
    float hardness;
} PointInOut;


vertex PointInOut pointVertex(PointVertex in [[stage_in]],
                                  constant SharedUniforms &sharedUniforms [[ buffer(kBufferIndexSharedUniforms) ]]
                               )
{
    PointInOut vertexOut;
   
    float4 position = in.position;
    
    // float4x4 modelMatrix = instanceUniforms[iid].modelMatrix;
    float4x4 modelViewMatrix = sharedUniforms.viewMatrix ;
    
    // Calculate the position of our vertex in clip space and output for clipping and rasterization
    float4x4 mvpMatrix = sharedUniforms.projectionMatrix * modelViewMatrix;
    
    // vertexOut.position = sharedUniforms.projectionMatrix * modelViewMatrix * position;
    vertexOut.position = mvpMatrix * position;
    // vertexOut.position = in;
    float pointSizeMeters = in.size;
    vertexOut.hardness = in.hardness;
    vertexOut.pointSizeInMeters = pointSizeMeters;
    vertexOut.positionInMeters = position;
    float pointSizeScreenSpace = pointSizeMeters * sharedUniforms.projectionMatrix[1][1]  / vertexOut.position.w;
    float pointSizeScreenPixels = pointSizeScreenSpace * sharedUniforms.pixelSize.y;
    vertexOut.pointSize =  pointSizeScreenPixels;
    vertexOut.color = in.color;
    return vertexOut;
}

fragment half4 pointFragment(PointInOut in [[stage_in]],constant SharedUniforms &sharedUniforms [[ buffer(kBufferIndexSharedUniforms) ]],
                               float2 pointCoord [[point_coord]])
{
    float2 centeredPointCoord = pointCoord - float2(0.5);
    float dist = 2.0*length(centeredPointCoord);
    float4 c = in.color;
    float radialFade = 1.0 - smoothstep(in.hardness, 1.0, dist);
    
    float4 u = sharedUniforms.u;
    float4 v = sharedUniforms.v;
    
    float4 spacePoint =  in.positionInMeters + in.pointSizeInMeters*(centeredPointCoord.x*u + centeredPointCoord.y*v);
    
    float noiseFactor = 1.0;
    
    if(sharedUniforms.noise){
        float noiseScale = 100.0;
        float noiseFactor =  noise(noiseScale*spacePoint.xyz);
        noiseFactor = mix(1.0,noiseFactor,sqrt(dist));
    }
    
    float alpha = noiseFactor*radialFade;

    float4 out_color = float4(c.r,c.g,c.b,c.a * alpha);
    
    return half4(out_color);
}


