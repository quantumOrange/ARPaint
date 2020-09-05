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
        noiseFactor =  noise(noiseScale*spacePoint.xyz);
        noiseFactor = mix(1.0,noiseFactor,sqrt(dist));
    }
    
    float alpha = noiseFactor*radialFade;

    float4 out_color = float4(c.r,c.g,c.b,c.a * alpha);
    
    return half4(out_color);
}


