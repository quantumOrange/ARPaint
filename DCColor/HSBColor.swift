//
//  HSBColor.swift
//  DCColor
//
//  Created by David Crooks on 21/02/2019.
//  Copyright © 2019 David Crooks. All rights reserved.
//

import Foundation
import UIKit

public struct HSBColor {
    public let hue:CGFloat
    public let saturation:CGFloat
    public let brightness:CGFloat
    public let alpha:CGFloat
}

extension HSBColor:Color {

    public var rgb:RGBColor {
        return hsbToRgb(hsb: self)
    }
    
    public var hsb:HSBColor {
        return self
    }
    
    public var uiColor: UIColor {
        return UIColor(hue:  radians2unitInterval(hue), saturation: saturation, brightness: brightness, alpha: alpha)
    }
   
}


//adapted from java http://kickjava.com/src/org/eclipse/swt/graphics/RGB.java.htm
func hsbToRgb(hsb:HSBColor)  -> RGBColor {
    let twopi = 2.0 * CGFloat.pi
    
    let   saturation =    hsb.saturation
    let   hue =           hsb.hue == twopi ? 0 : hsb.hue
    let   brightness =    hsb.brightness
    let      a = hsb.alpha
    
    var r:CGFloat = 0.0
    var b:CGFloat = 0.0
    var g:CGFloat = 0.0
    
    if (saturation == 0) {
        r = brightness
        g = brightness
        b = brightness
    }
    else
    {
        let hueZoneFloat =  3.0 * hue / .pi    /// === hue/60 degrees
        let hueZone = Int(hueZoneFloat);
        
        let f = hueZoneFloat - CGFloat(hueZone);
        let p = brightness * (1 - saturation);
        let q = brightness * (1 - saturation * f);
        let t = brightness * (1 - saturation * (1 - f));
        
        
        switch hueZone {
        case 0:
               r = brightness;
               g = t;
               b = p;

        case 1:
               r = q;
               g = brightness;
               b = p;

        case 2:
               r = p;
               g = brightness;
               b = t;

        case 3:
               r = p;
               g = q;
               b = brightness;

        case 4:
               r = t;
               g = p;
               b = brightness;
        default:
               r = brightness;
               g = p;
               b = q;
        }
    }
   
    // let blue = (int)(b * 255 + 0.5);
    return RGBColor(red:r,green:g,blue:b,alpha:a)
 }


