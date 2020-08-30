//
//  Noise.h
//  ARPaint
//
//  Created by David Crooks on 28/08/2020.
//  Copyright © 2020 David Crooks. All rights reserved.
//

#ifndef Noise_h
#define Noise_h

float3 hash( float3 p );
float gradientNoise(float3 p );
float fractGradientNoise(float3 v);

#endif /* Noise_h */
