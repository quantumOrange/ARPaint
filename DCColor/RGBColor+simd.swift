//
//  ColorSimd.swift
//  DCColor
//
//  Created by David Crooks on 18/02/2019.
//  Copyright © 2019 David Crooks. All rights reserved.
//

import Foundation
import simd

extension RGBColor {
    public var simd:SIMD4<Float> {
        return SIMD4<Float>(x: Float(red), y: Float(green), z: Float(blue), w: Float(alpha))
    }
}
