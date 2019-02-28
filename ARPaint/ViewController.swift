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
//import DCColor

extension MTKView : RenderDestinationProvider {
    
}
/*
extension Color {
    var simdValue:float4 {
        let (r,g,b,a) = rgbaComponents
        return float4(Float(r),Float(g),Float(b),Float(a))
    }
}
*/

class ViewController: UIViewController  {
    /*
    @IBOutlet weak var colorControl: DCColorControl!
    
    @IBAction func colorChanged(_ sender: DCColorControl) {
        paintGesture.color = sender.color.simdValue
    }
    */
    var paintGesture:PaintGestureRecognizer!
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
            renderer.drawRectResized(size: view.bounds.size)
        }
        
        paintGesture = PaintGestureRecognizer(points: renderer.points, session: session)
        view.addGestureRecognizer(paintGesture)
        //let color = UIColor.red
        
       // paintGesture.color = color.simdValue
       // colorControl.color = color
        
        
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
   
}

extension ViewController:MTKViewDelegate {
    // Called whenever view changes orientation or layout is changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }
    
    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        renderer.update()
    }
}

extension ViewController:ARSessionDelegate {
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
