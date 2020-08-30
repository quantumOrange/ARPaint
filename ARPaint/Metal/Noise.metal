//
//  Noise.metal
//  ARPaint
//
//  Created by David Crooks on 28/08/2020.
//  Copyright © 2020 David Crooks. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "Noise.h"

float3 hash( float3 p )
{
    p = float3( dot(p,float3(127.1,311.7, 74.7)),
              dot(p,float3(269.5,183.3,246.1)),
              dot(p,float3(113.5,271.9,124.6)));

    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float gradientNoise(float3 p )
{
    float3 i = floor( p );
    float3 f = fract( p );
    
    float3 u = f*f*(3.0-2.0*f);

    return mix( mix( mix( dot( hash( i + float3(0.0,0.0,0.0) ), f - float3(0.0,0.0,0.0) ),
                          dot( hash( i + float3(1.0,0.0,0.0) ), f - float3(1.0,0.0,0.0) ), u.x),
                     mix( dot( hash( i + float3(0.0,1.0,0.0) ), f - float3(0.0,1.0,0.0) ),
                          dot( hash( i + float3(1.0,1.0,0.0) ), f - float3(1.0,1.0,0.0) ), u.x), u.y),
                mix( mix( dot( hash( i + float3(0.0,0.0,1.0) ), f - float3(0.0,0.0,1.0) ),
                          dot( hash( i + float3(1.0,0.0,1.0) ), f - float3(1.0,0.0,1.0) ), u.x),
                     mix( dot( hash( i + float3(0.0,1.0,1.0) ), f - float3(0.0,1.0,1.0) ),
                          dot( hash( i + float3(1.0,1.0,1.0) ), f - float3(1.0,1.0,1.0) ), u.x), u.y), u.z );
}

float noise(float3 v,float amplitudeFactor,float scaleFactor, int interations ){
    float value = 0.0;
    float a = amplitudeFactor;
   
    for(int i=0;i<interations;i++){

        value +=  a*gradientNoise(v);
        v *= scaleFactor;
        a *= amplitudeFactor;
    }
    return value;
}

float noise(float3 v) {
    return noise(v, 0.5,2.0,10);
}
