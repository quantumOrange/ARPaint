//
//  PaintGestureRecognizer.swift
//  ARPaint
//
//  Created by David Crooks on 18/02/2019.
//  Copyright © 2019 David Crooks. All rights reserved.
//

import UIKit
import ARKit

class PaintGestureRecognizer: UIGestureRecognizer {
    let orientaion = UIInterfaceOrientation.portrait
    let points:Points
    let session:ARSession
    
    var drawDepth:Float = 0.2
    var brushSize:Float = 0.01
    var hardness:Float = 0.5
    var color:float4 = float4(x: 0, y: 0, z: 1, w: 1)
    
    var pointSpacing:Float{
       return 4.0 * brushSize
    }
    init(points:Points,session:ARSession) {
        self.points = points
        self.session = session
        super.init(target: nil, action: nil)
    }
    
    func paint(at p:float3){
        points.add(point:p, color:color, size:brushSize, hardness: hardness)
    }
    
    func screenPoint(for touches:Set<UITouch>) -> CGPoint? {
        guard   let touch = touches.first,
                let view = view else     { return nil }
        return touch.location(in: view)
    }
    
    func spacePoint(at screenPoint: CGPoint, frame: ARFrame) -> float3? {
        guard let size = view?.bounds.size else { return nil }
        //We want to intersect screen points with the plane infront of the camera
        // Create a transform with a translation of [drawDepth] meters in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -drawDepth
        
        //This transform represents a plane whose origin is in front of the camera. But it is in the x-z plane....
        let planeOrigin = simd_mul(frame.camera.transform, translation)
        
        //We want the x-y plane, parralele to the screen, so we need to rotate in the x-axis
        let xAxis = simd_float3(x: 1,
                                y: 0,
                                z: 0)
        
        let rotation = float4x4(simd_quatf(angle: 0.5 * .pi ,
                                           axis: xAxis))
        
        let plane = simd_mul(planeOrigin,rotation)
 
        return frame.camera.unprojectPoint(screenPoint, ontoPlane: plane, orientation:orientaion, viewportSize: size)
           
    }
    
    func spacePoint(touches: Set<UITouch>, session:ARSession) -> float3? {
        guard   let screenPoint = screenPoint(for: touches),
            let frame = session.currentFrame else { return nil }
        return spacePoint(at: screenPoint, frame:frame)
    }
    
    var lastDrawPoint:float3?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let p = spacePoint(touches: touches, session: session) {
             paint(at: p)
             lastDrawPoint = p
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentPoint = spacePoint(touches: touches, session: session),
            let lastDraw = lastDrawPoint
            {
                let drawPoints = linePoints(start: lastDraw, end: currentPoint, spacing: pointSpacing)
                
                drawPoints.forEach(paint)
                
                if let last = drawPoints.last {
                    lastDrawPoint = last
                }
            }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentPoint = spacePoint(touches: touches, session: session),
            let lastDraw = lastDrawPoint
        {
            linePoints(start: lastDraw, end: currentPoint, spacing: pointSpacing)
                .forEach(paint)
            
            lastDrawPoint = nil
        }
    }
    
    func linePoints(start:float3,end:float3,spacing:Float) -> [float3] {
        let dist = distance(start,end)
        
        let numberOfDrawPoints = Int(floor(dist/spacing))
        
        let v = end - start
        if numberOfDrawPoints > 0 {
            let drawPoints = (1...numberOfDrawPoints)
                                .map { start +  Float($0) * spacing *  v }
            print(drawPoints.count)
            return drawPoints
        } else {
            return []
        }
    }
    
}
