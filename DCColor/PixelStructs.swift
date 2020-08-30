//
//  PixelStructs.swift
//  PaintLab
//
//  Created by David Crooks on 27/02/2017.
//  Copyright © 2017 David Crooks. All rights reserved.
//

import Foundation
import UIKit


struct PixelSize {
    
    var width:Int
    var height:Int
    
    init(width:Int,height:Int){
        self.width = width
        self.height = height
    }
    
    init(size:CGSize,scale:CGFloat) {
        width = Int( size.width * scale )
        height = Int( size.height * scale )
    }
    
    var cgSize:CGSize {
        
        let scale = UIScreen.main.scale
        //let size = CGSize(width: width, height: height)
        //return size / scale
        return CGSize(width:CGFloat(width)/scale, height: CGFloat(height)/scale)
    }
    
    
}

struct PixelPoint {
    
    var x:Int
    var y:Int
    
    init(x:Int,y:Int){
        self.x = x
        self.y = y
    }
    
    init(p:CGPoint,scale:CGFloat) {
        x = Int( p.x * scale )
        y = Int( p.y * scale )
    }
    
    var cgPoint:CGPoint {
        
        let scale = UIScreen.main.scale
        let p = CGPoint(x: x, y: y)
        
        return p / scale
    }
    

}



struct PixelRect {
    
    var origin:PixelPoint
    var size:PixelSize
    
    var cgRect:CGRect {
        return CGRect(origin: origin.cgPoint, size: size.cgSize)
    }
    
}

extension CGPoint {
    
    var pixelPoint:PixelPoint {
        let scale = UIScreen.main.scale
        let pixels = scale*self
        return PixelPoint(x: Int(pixels.x), y: Int(pixels.y))
    }
    
}

extension CGSize {
    
    var pixelSize:PixelSize {
        let scale = UIScreen.main.scale
      //  let pixels = scale*self
        return PixelSize(width: Int(scale * width), height: Int(scale * height))
    }
    
}

extension CGRect {
    
    var pixelRect:PixelRect {
        return PixelRect(origin: origin.pixelPoint, size: size.pixelSize)
    }
    
}


