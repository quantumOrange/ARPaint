//
//  CapturedImage.h
//  ARPaint
//
//  Created by David Crooks on 30/08/2020.
//  Copyright © 2020 David Crooks. All rights reserved.
//

#ifndef CapturedImage_h
#define CapturedImage_h

#import "ShaderTypes.h"
#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;
typedef struct {
    float2 position [[attribute(kVertexAttributePosition)]];
    float2 texCoord [[attribute(kVertexAttributeTexcoord)]];
} ImageVertex;

typedef struct {
    float4 position [[position]];
    float2 texCoord;
} ImageColorInOut;


vertex ImageColorInOut capturedImageVertexTransform(ImageVertex in [[stage_in]]);
fragment float4 capturedImageFragmentShader(ImageColorInOut in [[stage_in]],texture2d<float, access::sample> capturedImageTextureY [[ texture(kTextureIndexY) ]],texture2d<float, access::sample> capturedImageTextureCbCr [[ texture(kTextureIndexCbCr) ]]);
 
#endif /* CapturedImage_h */
