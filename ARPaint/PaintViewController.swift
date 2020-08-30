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
import DCColor
import RxSwift
import RxCocoa

extension MTKView : RenderDestinationProvider {
    
}

class PaintViewController: UIViewController  {
    
    @IBOutlet weak var metalView: MTKView!
    
    @IBOutlet weak var swatch: DCSwatchButton!
    
    @IBOutlet weak var colorControl: DCColorControl!
    
    @IBAction func clear(_ sender: Any) {
    }
    var paintGesture:PaintGestureRecognizer!
    var tapGesture:UITapGestureRecognizer!
    var session: ARSession!
    var renderer: Renderer!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        session = ARSession()
        session.delegate = self
        
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.backgroundColor = UIColor.clear
        metalView.delegate = self
        
        guard metalView.device != nil else {
            print("Metal is not supported on this device")
            return
        }
        
        // Configure the renderer to draw to the view
        renderer = Renderer(session: session, metalDevice: metalView.device!, renderDestination: metalView,  orientaion: .portrait)
        renderer.drawRectResized(size: view.bounds.size)
       
        paintGesture = PaintGestureRecognizer( session: session)
        metalView.addGestureRecognizer(paintGesture)
        
        
        let (colorControlColor, paintPoints, colorContolIsVisable) = paintViewModel(
                                                            colorChanged:colorControl.rx.color.asObservable(),
                                                            swatchTapped:swatch.rx.tap.asObservable(),
                                                            drawPoints:paintGesture.drawPoints.asObservable()
                                                            )
        
        colorContolIsVisable
            .subscribe(onNext:
            { visible in
                self.colorControl.isHidden = false
               
                let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut, animations: {
                    self.colorControl.alpha = visible ? 1.0 : 0.0
                })
                
                animation.addCompletion({_ in
                    self.colorControl.isHidden = !visible
                })
                
                animation.startAnimation()
                
                //only paint when the color wheel is hidden
                self.paintGesture.isEnabled = !visible
            })
            .disposed(by: bag)
        
        
        colorControlColor
            .bind(to:swatch.rx.color)
            .disposed(by: bag)
        
        paintPoints
            .subscribe(onNext: {[weak self] verticies in
                    self?.renderer.points.add(vertices: verticies)
                })
            .disposed(by: bag)
        
        colorControl.color = UIColor.red
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

extension PaintViewController:MTKViewDelegate {
    // Called whenever view changes orientation or layout is changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }
    
    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        renderer.update()
    }
}

extension PaintViewController:ARSessionDelegate {
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
