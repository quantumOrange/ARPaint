//
//  CGPointExtension.swift
//  demoApp
//
//  Created by David Crooks on 23/01/2015.
//  Copyright (c) 2015 David Crooks. All rights reserved.
//

import Foundation
import UIKit

public func dot(_ left: CGPoint, right: CGPoint) -> CGFloat {
    return  left.x*right.x +  left.y*right.y
}

public func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x+right.x, y: left.y+right.y)
}

public func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x-right.x, y: left.y-right.y)
}

public func *(left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left*right.x, y:left*right.y)
}

public func *(left: CGPoint, right: CGAffineTransform) -> CGPoint {
    return left.applying(right)
}

public func *(left: CGPoint, right: CATransform3D) -> CGPoint {
    return left.applyTransform3D(transform: right)
}

public func /(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x/right, y:left.y/right)
}

public extension CGPoint {
    
    init(angle:CGFloat,radius:CGFloat) {
        self.init()
        x = radius*cos(angle)
        y = radius*sin(angle)
    }
    
    func distanceTo(_ p: CGPoint) -> CGFloat {
        let q = self
        return  (q-p).length()
    }
    
    func dot(_ q:CGPoint) -> CGFloat {
        let p = self
        return p.x * q.x + p.y * q.y
    }
    
    func cross(_ q:CGPoint) -> CGFloat {
        let p = self
        return p.x * q.y - p.y * q.x
    }
    
    func angle(_ q:CGPoint) -> CGFloat {
        let c = self.dot(q) / (self.length()    * q.length())
        return acos(c)
    }
    
    //The range of the angle is -π to π; an angle of 0 points to the right.
    var angle: CGFloat {
        return atan2(y, x)
    }
    
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    var normalized:CGPoint {
        let l = length()
        return CGPoint(x: x/l, y: y/l)
    }
    
    func unitVector() -> CGPoint {
        let l = length()
        return CGPoint(x: x/l, y: y/l)
    }
    
    func lengthSquared() -> CGFloat {
        return x*x + y*y
    }
    
    func midPoint(to point: CGPoint) -> CGPoint {
        let q = self
        let p = point
        var v = p-q
        v = 0.5*v
        
        return  q + v
    }
    
    func applyTransform3D(transform M: CATransform3D) -> CGPoint {
        let p = self
        var q = CGPoint.zero
        let pz:CGFloat = 1.0

        let pw:CGFloat = 1.0
        
        let  w = M.m14*p.x + M.m24*p.y + M.m34*pz + M.m44*pw
        q.x = (M.m11*p.x + M.m21*p.y + M.m31*pz + M.m41*pw)/w
        q.y = (M.m12*p.x + M.m22*p.y + M.m32*pz + M.m42*pw)/w

        return q
    }
    
    var isValid:Bool {
        if self.x.isNaN || self.y.isNaN {
            return false
        }
        return true
    }
}
