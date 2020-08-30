//
//  Color.swift
//  DCColor
//
//  Created by David Crooks on 04/03/2017.
//  Copyright © 2017 David Crooks. All rights reserved.
//

import Foundation
import UIKit

public enum ColorChannel:Int {
    case red, green, blue
    case hue, saturation, brightness
    case alpha
}

public protocol Color {

    var uiColor:UIColor {get}
    var hsb:HSBColor {get}
    var rgb:RGBColor {get}
   
    func colorWith(channel:ColorChannel,value:CGFloat) -> Color
    func value(forChannel channel:ColorChannel) -> CGFloat
    
}

public extension Color {
   
    func colorWith(channel:ColorChannel,value:CGFloat) -> Color {
        switch channel {
        case .red:
            let rgb = self.rgb
            return RGBColor(red: value, green: rgb.green, blue: rgb.blue, alpha: rgb.alpha)
            
        case .green:
            let rgb = self.rgb
            return RGBColor(red: rgb.red, green: value, blue: rgb.blue, alpha: rgb.alpha)
            
        case .blue:
            let rgb = self.rgb
            return RGBColor(red: rgb.red, green: rgb.green, blue: value, alpha: rgb.alpha)
            
        case .hue:
            let hsb = self.hsb
            return HSBColor(hue: value, saturation: hsb.saturation, brightness: hsb.brightness, alpha: hsb.alpha)
            
        case .saturation:
            let hsb = self.hsb
            return HSBColor(hue: hsb.hue, saturation: value, brightness: hsb.brightness, alpha: hsb.alpha)
            
        case .brightness:
            let hsb = self.hsb
            return HSBColor(hue: hsb.hue, saturation: hsb.saturation, brightness: value, alpha: hsb.alpha)
            
        case .alpha:
            if let hsb = self as? HSBColor {
               
                return HSBColor(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness, alpha:value)
            }
            else if let rgb = self as? RGBColor {
                return RGBColor(red: rgb.red, green: rgb.green, blue: value, alpha: rgb.alpha)
            } else {
                let rgb = self.rgb
                return UIColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: value)
            }
            
        }
    }
    
    func value(forChannel channel:ColorChannel) -> CGFloat {
        switch channel {
        
            case .red:
                return rgb.red
            case .green:
                return rgb.green
            case .blue:
                return rgb.blue
            
            case .hue:
                return hsb.hue
            case .saturation:
                return hsb.saturation
            case .brightness:
                return hsb.brightness
            case .alpha:
                return rgb.alpha
        }
    }
    
}

extension UIColor:Color {
    public var hsb: HSBColor {
        let twopi = 2.0 * CGFloat.pi
        var h: CGFloat = 0, s: CGFloat = 0, bright: CGFloat = 0, alpha: CGFloat = 0
        
        if getHue(&h, saturation: &s, brightness: &bright, alpha: &alpha) {
            return HSBColor(hue:twopi * h, saturation:s, brightness:bright,alpha:alpha)
        }
        
        var white: CGFloat = 0
        getWhite(&white, alpha: &alpha)
        return HSBColor(hue:0,saturation:0,brightness:white,alpha:alpha)
        
    }
    
    public var rgb: RGBColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return RGBColor(red:red,green:green,blue:blue,alpha:alpha)
        }
       
        var white: CGFloat = 0
        getWhite(&white, alpha: &alpha)
        
        return RGBColor(red:white,green:white,blue:white,alpha:alpha)
    }
    
    public var uiColor:UIColor {
        return self
    }
    
}

extension CGColor:Color {
    
    public var uiColor: UIColor {
        return UIColor(cgColor: self)
    }
    
    public var hsb: HSBColor {
        return uiColor.hsb
    }
    
    public var rgb: RGBColor {
        return uiColor.rgb
    }
    
}



