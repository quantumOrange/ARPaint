//
//  CGContextExtension.swift
//  DCColor
//
//  Created by David Crooks on 05/03/2017.
//  Copyright © 2017 David Crooks. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

extension CGContext  {
    
    public func fillPath(){
        self.fillPath(using: .winding)
    }
    
    public func addArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
       //TODO: - WARNING :- Not Working on iOS9.0
        //update - maybe fixed? changed clockwise from true to false
        let arc = CGMutablePath()
        
       // move(to: center)
        arc.addArc(center: center, radius: radius,
                   startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        addPath(arc)
    }
    
    public func addCircle(center: CGPoint, radius: CGFloat) {
        let side = radius*2.0
        addEllipse(in:CGRect.square(center: center, with:side))
    }
    
}

extension CGContext {
    
    func drawHueWheel(center:CGPoint,radius:CGFloat, thickness:CGFloat){
        
       // let color = UIColor.red
        drawColorWheel(center: center, radius: radius, thickness: thickness, color: UIColor.red, channel: .hue)
        
        /*
        //generate a set of pairs of angles and color at 360 points around the color wheel
        let colorsAngles = (0..<360).map{ CGFloat($0)/360.0 }.map{ ( UIColor(hue: $0, saturation: 1.0, brightness: 1.0, alpha: 1.0), $0*twoPi)}
        
        let innerRadius = radius - thickness
        let degreeWidth = twoPi*radius/360.0
        setLineWidth(degreeWidth)
        
        //for each pair draw a line with that color in a radial direction at that angle
        colorsAngles.forEach{
            let (color,angle) = $0
            setStrokeColor(color.cgColor)
            move(to: center + CGPoint(angle:angle, radius:innerRadius  ))
            addLine(to: center + CGPoint(angle:angle, radius:radius))
            strokePath()
        }
        */
    }
    
    /**
     Draws a color wheel -  a circlular color gradient with  a key color varying around the wheel on some color channel
     
     - Parameters:-
         - center: The center point pf the color wheel
         - radius: The outer radius of the wheel
         - thicknesss: The thickness of the wheel (so the inner radius = radius - thickness )
         - color: The key color which will be morphed around the wheel
         - channel: the color chanel (red, green, hue, ...) which will vary around the wheel
         - angularOffset: Defaults to zero.
         - angularMargin: If this is set the wheel won't go the whole way around the circle, but leave a margin.  Defaults to zero.
     */
    func drawColorWheel(center:CGPoint,radius:CGFloat, thickness:CGFloat, color:Color, channel: ColorChannel, angularOffset:CGFloat = 0,angularMargin:CGFloat = 0){
        //generate a set of pairs of angles and color at 360 points around the color wheel
        let oneDegreeIntervals = (0..<360).map { CGFloat($0)/360.0 }
        
        let colorsAngles = oneDegreeIntervals.map{ ( color.colorWith(channel: channel, value: $0), angularOffset + $0*(2.0*CGFloat.pi - angularMargin ))}
       
        
        let innerRadius = radius - thickness
        
        let degreeWidth = 2.0*CGFloat.pi*radius/360.0
        setLineWidth(degreeWidth)
        
        if  angularMargin > 0.05 {
            
            let c1 = colorsAngles[0].0
            let theta1 = colorsAngles[0].1
            let c2 = colorsAngles.last!.0
            let theta2 = colorsAngles.last!.1
            let r = 0.5*thickness
            
            setFillColor(c1.uiColor.cgColor)
            addCircle(center: center + CGPoint(angle:theta1, radius:innerRadius + r  ), radius:r )
            drawPath(using: .fill)
            
            setFillColor(c2.uiColor.cgColor)
            addCircle(center:center + CGPoint(angle:theta2, radius:innerRadius + r  ), radius: r)
            drawPath(using: .fill)
            
            
        }
        
        //for each pair draw a line with that color in a radial direction at that angle
        colorsAngles.forEach{
            let (color,angle) = $0
            setStrokeColor(color.uiColor.cgColor)
            move(to: center + CGPoint(angle:angle, radius:innerRadius  ))
            addLine(to: center + CGPoint(angle:angle, radius:radius))
            strokePath()
        }
        
    }
    
    ///Draws a color circle of all colors of a given brightness, hue varying around the circumferance and  saturation varying radially
    func drawColorCircle(center:CGPoint,radius:CGFloat, brightness:CGFloat){
       
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //generate a set of pairs of angles and color at 360 points around the color wheel
        let colorsAngles = (0..<360).map{ CGFloat($0)/360.0 }.map{ ( UIColor(hue: $0, saturation: 1.0, brightness:brightness, alpha: 1.0), $0*2.0*CGFloat.pi)}

        let degreeInRadians = 2.0*CGFloat.pi/360.0
        let dtheta = 1.2*degreeInRadians
        
        let gray = UIColor(white: brightness, alpha: 1.0).cgColor
        
        //for each pair draw a wedge at that angle and fill with a gradient from gray on the middel to the color hue at the circumference
        colorsAngles.forEach{
            let (color,angle) = $0
            
            //prepare to unclip
            saveGState()
            
            //draw the triangle/wedge
            move(to: center )
            addLine(to: center + CGPoint(angle:angle, radius:radius))
            addLine(to: center + CGPoint(angle:angle + dtheta, radius:radius))
            addLine(to: center )
            
            //clip to wedge and draw gradient in wedge
            clip()
            let colors = [gray,color.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors , locations: nil)
            {
                drawLinearGradient(gradient, start: center, end:center + CGPoint(angle:angle , radius:radius), options: .drawsAfterEndLocation)
            }
            
            //unclip
            restoreGState()
        }

    }
    
    ///Draws a color circle of all colors of a given hue
    func drawColorCircle(center:CGPoint,radius:CGFloat, hue:CGFloat){
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let third = 2.0*CGFloat.pi/3.0
        
        //generate a set of pairs of angles and color at 360 points around the color wheel
        let array = (0..<120).map{ CGFloat($0)/120.0 }
        
        let hueAngle = hue*2.0*CGFloat.pi
        
       
        //We create triples of saturation, brightness and angle
        
        //1) We start with a bright saturated color and go a third of the way round the wheel to black
        let satBrightAngles0 = array.map{ ( CGFloat(1.0) - $0  ,CGFloat( 1.0 ) - $0   ,hueAngle +  $0*third)}
        //2)Then another third going from black through gray to white
        let satBrightAngles1 = array.map{ ( CGFloat(0.0) ,  $0, hueAngle + third + $0*third)  }
        //3)then from white back to the color and point we started with
        let satBrightAngles2 = array.map{ ( $0 , CGFloat( 1.0) , hueAngle + 2.0*third + $0*third)  }
        
        //stick them all together to go all round the wheel
        let satBrightAngles = satBrightAngles0 + satBrightAngles1 + satBrightAngles2
        
        let colorAngles = satBrightAngles.map {  ( UIColor(hue:hue,saturation: $0.0, brightness:$0.1,alpha:1.0) , $0.2 ) }
            
            
        let degreeInRadians = 2.0*CGFloat.pi/360.0
        let dtheta = 1.3*degreeInRadians
        
        let centerColor =  UIColor(hue: hue, saturation: CGFloat(0.5) , brightness:CGFloat(0.5), alpha:CGFloat(1.0)).cgColor
        
        //for each pair draw a wedge at that angle and fill with a gradient from gray on the middel to the color hue at the circumference
        colorAngles.forEach{
            let (color,angle) = $0
            
            //prepare to unclip
            saveGState()
            
            //draw the triangle/wedge
            move(to: center )
            addLine(to: center + CGPoint(angle:angle, radius:radius))
            addLine(to: center + CGPoint(angle:angle + dtheta, radius:radius))
            addLine(to: center )
            
            //clip to wedge and draw gradient in wedge
            clip()
            let colors = [centerColor,color.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors , locations: nil)
            {
                drawLinearGradient(gradient, start: center, end:center + CGPoint(angle:angle , radius:radius), options: .drawsAfterEndLocation)
            }
            
            //unclip
            restoreGState()
        }
        
    }

    
    func drawLinearHueGradient(rect:CGRect,  color:Color) {
        let numLines = Int(rect.width)
        let colorsPositions = (0..<numLines).map{CGFloat($0)}.map{ ( color.colorWith(channel: .hue, value: $0/rect.width), $0)}
        
        setLineWidth(rect.width/CGFloat(numLines))
        //for each pair draw a line with that color in a radial direction at that angle
        colorsPositions.forEach{
            let (color,x) = $0
            setStrokeColor(color.uiColor.cgColor)
            move(to:  CGPoint(x:rect.topLeft.x + x, y:rect.topLeft.y))
            addLine(to: CGPoint(x:rect.bottomLeft.x + x, y:rect.bottomLeft.y))
            strokePath()
        }
    }
    
}

