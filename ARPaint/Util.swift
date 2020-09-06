//
//  Util.swift
//  RayBreak
//
//  Created by David Crooks on 08/02/2019.
//  Copyright © 2019 caroline. All rights reserved.
//

import Foundation


extension Array {
    var byteLength:Int {
        return count * MemoryLayout<Element>.stride
    }
}

func time(_ lable:String,_  process: () -> ())
{
    let start = DispatchTime.now()
    process()
    let end = DispatchTime.now()
    
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds 
    let timeIntervalInMS = Double(nanoTime) / 1_000_000
    
    let t = String(format: "%.2f", timeIntervalInMS)
    let frameFraction = String(format: "%.2f", timeIntervalInMS / 16.0)
    print("Time for \(lable): \(t) ms, frame fraction: \(frameFraction)")
}

func randomVector() -> SIMD3<Float> {
    let r = Float.random(in: 0...1)
    let theta = Float.random(in: 0...2*Float.pi)
    let phi = Float.random(in: 0...2*Float.pi)
    
    return SIMD3<Float>(
                            r*sin(theta)*cos(phi),
                             r*sin(theta)*sin(phi),
                              r*cos(theta)
                        )
}

