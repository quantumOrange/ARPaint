//
//  mapRange.swift
//  DCGeometry
//
//  Created by David Crooks on 06/03/2017.
//  Copyright © 2017 David Crooks. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat  {
    static var unitRange:ClosedRange<CGFloat> {
        return  ClosedRange<CGFloat>(uncheckedBounds: (lower:0,  upper:1))
    }
}

public extension ClosedRange where Bound:Numeric {
    
    func clamp(value:Bound) ->  Bound {
        return  Swift.min(upperBound,Swift.max(lowerBound,value))
    }
    
   
}

public extension ClosedRange where Bound == CGFloat {
    
    func proportion(ofValue v:CGFloat) -> CGFloat {

        return (v - lowerBound ) / (upperBound - lowerBound)
    }
    
    func value(atProportion p:CGFloat) -> CGFloat {
        return lowerBound +  p * (upperBound - lowerBound)
    }
    
}

public func mapRange(fromRange:ClosedRange<CGFloat>, toRange:ClosedRange<CGFloat>) -> (CGFloat) -> CGFloat {
    return { x in
        let clampedValue = fromRange.clamp(value: x)
        let p = fromRange.proportion(ofValue: clampedValue)
        return toRange.value(atProportion: p)
    }
}

public extension CGRect {
    var rangeX:ClosedRange<CGFloat> {
        return ClosedRange(uncheckedBounds: (lower:origin.x,  upper:origin.x + size.width))
    }
    var rangeY:ClosedRange<CGFloat> {
        return ClosedRange(uncheckedBounds: (lower:origin.y,  upper:origin.y + size.height))
    }
}
