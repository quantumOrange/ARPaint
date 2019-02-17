//
//  ViewController.swift
//  ARMetalTest
//
//  Created by David Crooks on 07/02/2019.
//  Copyright © 2019 David Crooks. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import ARKit

extension MTKView : RenderDestinationProvider {
    
}

class ViewController: UIViewController, MTKViewDelegate, ARSessionDelegate {
    
    var session: ARSession!
    var renderer: Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        session = ARSession()
        session.delegate = self
        
        // Set the view to use the default device
        if let view = self.view as? MTKView {
            view.device = MTLCreateSystemDefaultDevice()
            view.backgroundColor = UIColor.clear
            view.delegate = self
            
            guard view.device != nil else {
                print("Metal is not supported on this device")
                return
            }
            
            // Configure the renderer to draw to the view
            renderer = Renderer(session: session, metalDevice: view.device!, renderDestination: view,  orientaion: .portrait)
            //view.drawableSize
            renderer.drawRectResized(size: view.bounds.size)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(gesture:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        session.pause()
    }
    
    @objc
    func handleTap(gesture: UITapGestureRecognizer) {
        // Create anchor using the camera's current position
        if let currentFrame = session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
           
            session.add(anchor: anchor)
 
        }
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
        
        if let p = frame.camera.unprojectPoint(screenPoint, ontoPlane: plane, orientation:interfaceOrientation, viewportSize: view.bounds.size) {
            renderer.points.add(point:p, color:float4(1.0,0.0,0.0,1.0), size:0.01, hardness: 0.1 )
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
    
    @IBAction func selectMode(_ sender: UISegmentedControl) {
        if let mode = DisplayMode(rawValue:sender.selectedSegmentIndex) {
            renderer.displayMode = mode
        }
        //switsender.selectedSegmentIndex
    }
    // Called whenever view changes orientation or layout is changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }
    
    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        renderer.update()
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
