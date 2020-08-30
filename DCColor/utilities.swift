//
//  utilities.swift
//  DCColor
//
//  Created by David Crooks on 24/03/2017.
//  Copyright © 2017 David Crooks. All rights reserved.
//

import Foundation
import UIKit

func lerp<T:Numeric>(x0:T,x1:T,t:T) -> T {
    return  (1 - t)*x0 + t*x1
}

func clamp<T:Comparable>(value:T,minimum:T,maximum:T ) -> T {
    return max( minimum ,min(value, maximum   ))
}

func positiveMod(_ x:CGFloat) -> CGFloat {
    var (_,s) = modf(x)
    if (x < 0.0) {
        s = (x + 1.0)
    }
    return s
}

func radians2unitInterval(_ theta:CGFloat) -> CGFloat {
    let twopi = 2.0 * CGFloat.pi
    return positiveMod(theta / twopi)
}

func degreesToRadians(_ theta:CGFloat) -> CGFloat {
    return 2.0*CGFloat.pi*theta/360.0
}

func radianToDegrees(_ theta:CGFloat) -> CGFloat {
    return 360.0*theta/(2.0*CGFloat.pi)
}
