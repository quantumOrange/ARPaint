//
//  File.swift
//  DCColor
//
//  Created by David Crooks on 21/02/2019.
//  Copyright © 2019 David Crooks. All rights reserved.
//

import Foundation
import UIKit

public struct RGBColor {
    public let red:CGFloat
    public let green:CGFloat
    public let blue:CGFloat
    public let alpha:CGFloat
    
    public init(red:CGFloat = 0.0,green:CGFloat = 0.0,blue:CGFloat = 0.0,alpha:CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

extension RGBColor:Color {
    public var rgb:RGBColor {
        return self
    }
    
    public var hsb:HSBColor {
        return rgbToHsb(rgb: self)
    }
    
    public var uiColor:UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

//adapted from java http://kickjava.com/src/org/eclipse/swt/graphics/RGB.java.htm
func rgbToHsb(rgb:RGBColor) -> HSBColor {
    let r = rgb.red;
    let g = rgb.green
    let b = rgb.blue
 
    let maxChannel = max(r, max( g, b))
    let minChannel = min(r, min(g, b))
    let delta = maxChannel - minChannel
    var hue:CGFloat = 0
    let brightness = maxChannel
    let saturation = ( maxChannel == 0 ) ? 0 : delta / maxChannel
    
    if delta != 0
    {
        if r == maxChannel
        {
            hue = (g - b) / delta;
        }
        else
        {
            if g == maxChannel
            {
                hue = 2 + (b - r) / delta;
            }
            else
            {
                hue = 4 + (r - g) / delta;
            }
        }
        hue *= (CGFloat.pi / 3.0);
        if (hue < 0) {
            hue += 2.0 * .pi
        }
    }
    
    return HSBColor(hue:hue,saturation:saturation,brightness:brightness,alpha:rgb.alpha)
 }

func lerp(from rgb0: RGBColor, to rgb1:RGBColor, value:CGFloat) -> RGBColor {
    
    func lerp(x0:CGFloat,x1:CGFloat) -> CGFloat {
        return  (1.0 - value)*x0 + value*x1
    }
    
    let (r,g,b,a) = (
        lerp(x0: rgb0.red, x1: rgb1.red),
        lerp(x0: rgb0.green, x1: rgb1.green),
        lerp(x0: rgb0.blue, x1: rgb1.blue),
        lerp(x0: rgb0.alpha, x1: rgb1.alpha)
    )
    
    let newColor = RGBColor(red: r, green: g, blue: b, alpha: a)
    
    return newColor
}
