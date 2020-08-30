//
//  DCHueCircleControl.swift
//  DCColor
//
//  Created by David Crooks on 07/03/2017.
//  Copyright © 2017 David Crooks. All rights reserved.
//

import UIKit



@IBDesignable
public class DCHueCircleControl: DCColorControl {
    //MARK:- Inspectables
    
    //In degrees
    @IBInspectable
    public var angularMarginDegrees:CGFloat = 40.0 {
        didSet{
            layoutSubviews()
        }
    }
    
    @IBInspectable
    public var angularOffSetDegrees:CGFloat = 20.0

    @IBInspectable
    public var wheelThickness:CGFloat = 20.0 {
        didSet {
            layoutSubviews()
        }
    }
    
    @IBInspectable
    public var space:CGFloat = 5.0 {
        didSet {
            layoutSubviews()
        }
    }

    @IBInspectable
    public var swatchRadius:CGFloat = 15.0 {
        didSet {
            
            brightnessSwatch.radius = swatchRadius
            colorSwatch.radius = swatchRadius
        }
    }
    
    @IBInspectable
    public var iColor:UIColor {
        get {
            return color.uiColor
        }
        set {
            color = newValue
        }
    }
    
    var angularMargin:CGFloat {
        get {
            return degreesToRadians(angularMarginDegrees)
        }
    }
    
    var angularOffSet:CGFloat {
        get {
            return degreesToRadians(angularOffSetDegrees)
        }
    }
    

//MARK:-Computed Properites
    var postionForColorSwatch:CGPoint {
        return  bounds.center + CGPoint(angle:hsbColor.hue, radius:hsbColor.saturation * colorCircleRadius)
    }
    
    var postionForBrightnessSwatch:CGPoint {
        return bounds.center + CGPoint(angle:0, radius:brightnessWheelRadius - 0.5*wheelThickness)
    }
    
    var colorCircleRadius:CGFloat {
        return brightnessWheelRadius - space - wheelThickness
    }
    
    ///Outter radius of brightness control ring
    var brightnessWheelRadius:CGFloat {
        return 0.5*frame.size.width
    }
    
    //MARK:- initiliszation
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override func awakeFromNib() {
        setup()
    }
    
    public override func prepareForInterfaceBuilder() {
        setup()
    }
    
    private var isSetup = false
    
    private func setup(){
        if isSetup { return }
        
        brightnessSwatchContainer = UIView(frame: bounds)
        brightnessSwatchContainer.isUserInteractionEnabled = false
        addSubview(brightnessSwatchContainer)
        
        brightnessSwatch = DCSwatch(color: UIColor.black, radius: swatchRadius)
        brightnessSwatchContainer.addSubview(brightnessSwatch)
        
        colorSwatch = DCSwatch(color: UIColor.yellow, radius: swatchRadius)
        addSubview(colorSwatch)
       
        isSetup = true
    }
    var brightnessSwatchCenter:CGPoint {
        return convert(brightnessSwatch.center, from: brightnessSwatchContainer)
    }
    //MARK:- Touch 
    //var didDragHandel = false
    func updateDragState(firstPoint:CGPoint, currentPoint:CGPoint) -> Bool {
        let dragRadius = 2.0*colorSwatch.bounds.size.width
        switch colorSelection {
        case .none:
            let dist = firstPoint.distanceTo(currentPoint)
            let tolerance:CGFloat = 3.0
            if  dist > tolerance {
                
                if firstPoint.distanceTo(bounds.center) < colorCircleRadius {
                    //picking hue and saturation
                    if firstPoint.distanceTo(colorSwatch.center) > dragRadius {
                        //started too far from swatch
                        colorSelection = .failed
                        return true
                    }
                    colorSelection = .hueSaturation(colorSwatch.center)
                }
                else if  firstPoint.distanceTo(bounds.center) < brightnessWheelRadius {
                    //picking brightness
                    let c = brightnessSwatchCenter
                    
                    if firstPoint.distanceTo(c) > dragRadius {
                        //started too far from swatch
                        colorSelection = .failed
                        return  true
                    }
                    colorSelection = .outerRing(c)
                }
            }
            return  true
        case .outerRing(let brightSwatchStartPoint):
            
            let drag =  currentPoint - firstPoint
            let p = brightSwatchStartPoint + drag
            
            let angle = angleInOuterColorPicker(at: p)
            
            let twopi = 2.0 * CGFloat.pi
            
            let isInMargin = angle  < angularOffSet ||  angle > twopi - angularMargin + angularOffSet
           
            if isInMargin {
                
                if angle > .pi {
                    colorSelection = .outerRingCompleting(.high)
                }
                else {
                    colorSelection = .outerRingCompleting(.low)
                }
                
                return false
            }
            return true
        case .outerRingCompleting:
            colorSelection = .complete
            return false
        case .hueSaturation,  .failed, .complete:
            return true
        }
    }
    
    var initialTouchPoint:CGPoint?
    var lastTouchPoint:CGPoint?
    enum ColorEndPoint {
        case low
        case high
    }
    enum ColorDragState {
        case hueSaturation(CGPoint)
        case outerRing(CGPoint)
        case outerRingCompleting(ColorEndPoint)
        case complete
        case failed
        case none
    }
    
    var colorSelection:ColorDragState = .none
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        colorSelection = .none
        print("begin tracking:\(colorSelection)")
        let touchPoint  = touch.location(in: self)
        initialTouchPoint = touchPoint
        
        if touchPoint.distanceTo(bounds.center) >  brightnessWheelRadius{
            colorSelection = .failed
            return false
        }
        return true
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        print("continue tracking 1:\(colorSelection)")
        let p = touch.location(in: self)
        let shouldContinue = updateDragState(firstPoint: initialTouchPoint!, currentPoint: p)
        
        let didChangeColor = handelDrag(from: initialTouchPoint!, to:p, for:colorSelection)
        
        if didChangeColor {
            sendActions(for: shouldContinue ? .editingChanged : .valueChanged)
        }
        
        lastTouchPoint = p
        print("continue tracking 2:\(colorSelection)")
        return shouldContinue
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        print("end tracking 1:\(colorSelection)")
        guard let p = touch?.location(in: self) else {
            colorSelection = .none
            return
        }
         _ = updateDragState(firstPoint: initialTouchPoint!, currentPoint: p)
        
        let didChangeColor = handelDrag(from:initialTouchPoint!, to:p, for:colorSelection)
        
        if didChangeColor {
            sendActions(for: .valueChanged)
        }
        else {
            handleTap(at: p)
        }
        
        initialTouchPoint = nil
        colorSelection = .none
        print("end tracking 2:\(colorSelection)")
        super.endTracking(touch, with: event)
    }
    
    /**
     - returns bool if colr was changed
    */
    func handelDrag(from start:CGPoint, to end:CGPoint,for selection:ColorDragState ) -> Bool {
        let drag = end - start
        
        switch  selection {
        case .hueSaturation(let hueSwatchStart):
            let p = hueSwatchStart + drag
            color = colorForHueSaturation(at: p)
            return true
        case .outerRing(let brightSwatchStartPoint):
            let p = brightSwatchStartPoint + drag
            color = colorForBrightness(at: p)
            return true
        case .outerRingCompleting(let colorEndpoint):
            switch colorEndpoint {
            case .high:
                    hsbColor = HSBColor(hue:hsbColor.hue,
                                        saturation:hsbColor.saturation,
                                        brightness:1.0,
                                        alpha:hsbColor.alpha)
            case .low:
                    hsbColor = HSBColor(hue:hsbColor.hue,
                                        saturation:hsbColor.saturation,
                                        brightness:0.0,
                                        alpha: hsbColor.alpha)
            }
            return true
        case .none, .failed, .complete:
            return false
        }
    }
    
    func colorForHueSaturation(at p:CGPoint) -> HSBColor {
        let dist = p.distanceTo(bounds.center)
        //picking hue and saturation
        let saturation = clamp(value: dist / colorCircleRadius, minimum: 0.0, maximum: 1.0)
        let hueAngle = (p - bounds.center).angle
        
        //print( "hueAngle: \(hueAngle), sat:\(saturation)" )
      //  let saturationColor = color.colorWith(channel: .saturation, value: saturation)
        
         return HSBColor(hue: hueAngle, saturation: saturation, brightness: hsbColor.brightness, alpha: hsbColor.alpha)
       // return saturationColor.colorWith(hueAngle: hueAngle)
    }
    
    func angleInOuterColorPicker(at p: CGPoint) -> CGFloat {
        let theta  = (p - bounds.center).angle
        let twopi = 2.0 * CGFloat.pi
        return theta < 0.0 ? theta + twopi : theta
    }
    
    func colorForBrightness(at p: CGPoint)-> HSBColor {
        
        let angle = angleInOuterColorPicker(at:p)
        return HSBColor(hue: hsbColor.hue, saturation: hsbColor.saturation, brightness: brightness(forAngle:angle), alpha: hsbColor.alpha)
      //  return hsbColor.colorWith(channel: .brightness, value:brightness(forAngle:angle))
    }
    
    func handleTap(at p:CGPoint){
        
        if let initialTouch = initialTouchPoint {
            let tapDragTolerance:CGFloat = 20.0
            if p.distanceTo(initialTouch) > tapDragTolerance {
                return
            }
        }
        
        let dist = p.distanceTo(bounds.center)
        if dist < colorCircleRadius {
           
            UIView.animate(withDuration: 0.3, animations: {
                self.color = self.colorForHueSaturation(at: p)
            })
            
            sendActions(for: .valueChanged)
        }
        else if  dist < brightnessWheelRadius {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.color =  self.colorForBrightness(at:p)
            })
            
            sendActions(for: .valueChanged)
        }
    }
    
    func angle(forBrightness b:CGFloat) -> CGFloat {
        let max = 2.0*CGFloat.pi - angularMargin
        return angularOffSet + max*b
    }
    
    func brightness(forAngle theta:CGFloat) -> CGFloat{
       //let twopi = 2.0 * CGFloat.pi
        //let alpha = theta < 0.0 ? theta + twopi : theta
        let angle =   theta - angularOffSet
        let max = 2.0*CGFloat.pi - angularMargin

        return clamp(value: angle/max, minimum: 0, maximum: 1)
    }
    
    func isInMargin(_ theta:CGFloat) -> Bool {
        return theta > angularOffSet &&  theta < 2.0*CGFloat.pi - angularMargin + angularOffSet
    }
    
    //MARK:- Everything Else
    
    var brightnessSwatch:DCSwatch!
    var brightnessSwatchContainer:UIView!
    var colorSwatch:DCSwatch!

    public override func layoutSubviews() {
        super.layoutSubviews()
        colorSwatch.center = postionForColorSwatch
        brightnessSwatch.center = postionForBrightnessSwatch
    }
    
    var hsbColor:HSBColor  = HSBColor(hue:0,saturation:1,brightness:1,alpha:1){
        
        didSet {
            
            
            brightnessSwatch.color = color
            colorSwatch.color = color
            colorSwatch.center = postionForColorSwatch
            
            brightnessSwatchContainer.transform = CGAffineTransform.init(rotationAngle: angle(forBrightness:  hsbColor.brightness))
            setNeedsDisplay()
        }
        
        
    }
    
    public override  var color:Color {
        get {
            return hsbColor
        }
        set {
            hsbColor = newValue.hsb
        }
    }

    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {return}
        
        context.drawColorWheel(center: rect.center, radius: brightnessWheelRadius, thickness: wheelThickness, color:hsbColor , channel: .brightness,angularOffset:angularOffSet, angularMargin:angularMargin)
        
        context.drawColorCircle(center: rect.center, radius: colorCircleRadius  , brightness: hsbColor.brightness)
        
    }
    
}
