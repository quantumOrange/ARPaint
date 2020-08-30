//
//  PaintGestureRecognizer.swift
//  ARPaint
//
//  Created by David Crooks on 18/02/2019.
//  Copyright © 2019 David Crooks. All rights reserved.
//

import UIKit
import ARKit
import RxCocoa

protocol PaintGestureDelagate {
    func add(point:SIMD3<Float>, color:SIMD4<Float>, size:Float, hardness:Float)
}

class PaintGestureRecognizer: UIGestureRecognizer {
    let orientaion = UIInterfaceOrientation.portrait
   
    let drawPoints:BehaviorRelay<[SIMD3<Float>]> = BehaviorRelay(value: [])
    let session:ARSession
    
    var drawDepth:Float = 0.1
    var pointSpacing:Float = 0.05 
    
    init(session:ARSession) {
       
        self.session = session
        super.init(target: nil, action: nil)
    }
   
    func screenPoint(for touches:Set<UITouch>) -> CGPoint? {
        guard   let touch = touches.first,
                let view = view else     { return nil }
        return touch.location(in: view)
    }
    
    func spacePoint(at screenPoint: CGPoint, frame: ARFrame) -> SIMD3<Float>? {
        guard let size = view?.bounds.size else { return nil }
        //We want to intersect screen points with the plane infront of the camera
        // Create a transform with a translation of [drawDepth] meters in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -drawDepth
        
        //This transform represents a plane whose origin is in front of the camera. But it is in the x-z plane....
        let planeOrigin = simd_mul(frame.camera.transform, translation)
        
        //We want the x-y plane, parralel to the screen, so we need to rotate in the x-axis
        let xAxis = simd_float3(x: 1,
                                y: 0,
                                z: 0)
        
        let rotation = float4x4(simd_quatf(angle: 0.5 * .pi ,
                                           axis: xAxis))
        
        let plane = simd_mul(planeOrigin,rotation)
 
        return frame.camera.unprojectPoint(screenPoint, ontoPlane: plane, orientation:orientaion, viewportSize: size)
           
    }
    
    func spacePoint(touches: Set<UITouch>, session:ARSession) -> SIMD3<Float>? {
        guard   let screenPoint = screenPoint(for: touches),
            let frame = session.currentFrame else { return nil }
        return spacePoint(at: screenPoint, frame:frame)
    }
    
    var lastDrawPoint:SIMD3<Float>?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let p = spacePoint(touches: touches, session: session) {
            //print("began:")
            drawPoints.accept([p])
             lastDrawPoint = p
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentPoint = spacePoint(touches: touches, session: session),
            let lastDraw = lastDrawPoint
            {
              // print("moved:")
                let points = linePoints(start: lastDraw, end: currentPoint, spacing: pointSpacing)
                
                drawPoints.accept(points)
                
                if let last = points.last {
                    //print("set last points to \(last)")
                    lastDrawPoint = last
                }
            }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentPoint = spacePoint(touches: touches, session: session),
            let lastDraw = lastDrawPoint
        {
            //print("end:")
           let points = linePoints(start: lastDraw, end: currentPoint, spacing: pointSpacing)
                //.forEach(paint)
            drawPoints.accept(points)
            lastDrawPoint = nil
        }
    }
    
    func linePoints(start:SIMD3<Float>,end:SIMD3<Float>,spacing:Float) -> [SIMD3<Float>] {
        let dist = distance(start,end)
        
        let numberOfDrawPoints = Int(floor(dist/spacing))
        
        let dv = dist/Float(numberOfDrawPoints)
        
        let v = end - start
        if numberOfDrawPoints > 0 {
            let drawPoints = (1...numberOfDrawPoints)
                                .map { start +  Float($0) * dv *  v }
            //print("     Line:\(start) -> \(end)")
            //print("     points:\(drawPoints.count) dist :\(dist)")
            
            return drawPoints
        } else {
            return []
        }
    }
    
}
