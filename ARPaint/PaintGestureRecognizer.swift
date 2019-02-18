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
    
    init(points:Points,session:ARSession) {
        self.points = points
        self.session = session
        super.init(target: nil, action: nil)
    }
    
    func paint(at screenPoint:CGPoint,frame:ARFrame){
        // Create a transform with a translation of 0.2 meters in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        let planeOrigin = simd_mul(frame.camera.transform, translation)
        
        let xAxis = simd_float3(x: 1,
                                y: 0,
                                z: 0)
        
        
        let rotation = float4x4(simd_quatf(angle: 0.5 * .pi ,
                                           axis: xAxis))
        
        let plane = simd_mul(planeOrigin,rotation)
        
        
        if  let size = view?.bounds.size,
            let p = frame.camera.unprojectPoint(screenPoint, ontoPlane: plane, orientation:orientaion, viewportSize: size) {
                points.add(point:p, color:float4(1.0,0.0,0.0,1.0), size:0.01, hardness: 0.1 )
                print("p:\(p)")
        }
    }
    
    func paint(at touches:Set<UITouch>){
        if let currentFrame = session.currentFrame,
            let touch = touches.first {
            let screenPoint = touch.location(in: view)
            paint(at: screenPoint, frame: currentFrame)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        paint(at: touches)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        paint(at: touches)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        paint(at: touches)
    }
    
}
