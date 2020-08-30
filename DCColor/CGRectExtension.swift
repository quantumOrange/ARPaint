//
//  CGRectExtension.swift
//  demoApp
//
//  Created by David Crooks on 23/01/2015.
//  Copyright (c) 2015 David Crooks. All rights reserved.
//

import Foundation
import UIKit


public extension CGRect {
    
    init(center:CGPoint,   size:CGSize) {
        self.init(origin:center,size:size)
        defer{
            self.center = center
        }
    }
    
    static func square(center:CGPoint, with side:CGFloat) -> CGRect {
        return CGRect(center:center,size:CGSize(width:side,height:side))
    }
    
    var bottomRight:CGPoint {
        get {
            return CGPoint(x: origin.x  + size.width, y: origin.y +  size.height)
        }
        set {
            origin = CGPoint(x: newValue.x - size.width, y: newValue.y - size.height)
        }
    }
    
    var topRight:CGPoint {
        get {
            return CGPoint(x: origin.x  +  width, y: origin.y )
        }
        set {
            origin = CGPoint(x: newValue.x - size.width, y: newValue.y)
        }
    }
    
    var bottomLeft:CGPoint {
        get {
            return CGPoint(x: origin.x  , y: origin.y +  size.height)
        }
        set {
            origin = CGPoint(x: newValue.x, y: newValue.y - size.height)
        }
    }
    
    var topLeft:CGPoint {
        get {
            return origin
        }
        set {
            origin = newValue
        }
    }
    
    var center:CGPoint {
        get {
            return CGPoint(x: origin.x  + 0.5*size.width, y: origin.y + 0.5*size.height)
        }
        set {
            origin = CGPoint(x: newValue.x - 0.5*size.width, y: newValue.y - 0.5*size.height)
        }
    }
    
    var topCenter:CGPoint {
        get {
            return CGPoint(x: origin.x + 0.5*size.width, y: origin.y)
        }
        set {
            origin = CGPoint(x: newValue.x - 0.5*size.width, y: newValue.y)
        }
    }
    
    var bottomCenter:CGPoint {
        get {
            return CGPoint(x: origin.x  + 0.5*size.width, y: origin.y +  size.height)
        }
        set {
            origin = CGPoint(x: newValue.x - 0.5*size.width, y: newValue.y - size.height)
        }
    }
    
    var leftCenter:CGPoint {
        get {
            return CGPoint(x: origin.x , y: origin.y +  0.5*size.height)
        }
        set {
            origin = CGPoint(x: newValue.x , y: newValue.y - 0.5*size.height)
        }
    }
    
    var rightCenter:CGPoint {
        get {
            return CGPoint(x: origin.x  + size.width, y: origin.y +  0.5*size.height)
        }
        set {
            origin = CGPoint(x: newValue.x - size.width, y: newValue.y - 0.5*size.height)
        }
    }
    
}

public extension CGRect {
    
    /*
     We want to find if a point is inside the rect, or if outside, where outside:
            |           |
    topleft | top       |  topright
    ________|___________|_________
            |           |
     left   |  inside   |  right
            |   rect    |
     _______|___________|_________
            |           |
     bottom |           |  bottom
     left   |   bottom  |   right
     
    */
    
    enum quadrant {
        case top,bottom,left,right,topLeft,topRight,bottomLeft,bottomRight,inside
    }
    
    func pointInQuadrant(_ p:CGPoint) -> quadrant {
        let o = origin
        let farCorner = o + CGPoint(x: size.width,y: size.height)
        
        if contains(p){
            return .inside
        }
        else if p.x < origin.x {
            //Left
            if p.y < origin.y {
                //Top
                return .topLeft
            }
            else if p.y > farCorner.y {
                //Bootom
                return .bottomLeft
            }
            else {
                //Middle
                return .left
            }
        }
        else if p.x > farCorner.x{
            //Right
            if p.y < origin.y {
                //Top
                return .topRight
            }
            else if p.y > farCorner.y {
                //Bottom
                return .bottomRight
            }
            else {
                //Middle
                return .right
            }
        }
        else
        {
            //Middle
            if p.y < origin.y {
                //Top
                return .top
            }
            else if p.y > farCorner.y {
                //Bottom
                return .bottom
            }
            else {
                //Middle
                return .inside
            }
        }
    }
    
}
