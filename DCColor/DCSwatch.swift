//
//  DCSwatch.swift
//  DCColor
//
//  Created by David Crooks on 06/03/2017.
//  Copyright © 2017 David Crooks. All rights reserved.
//

import UIKit

@IBDesignable
public class DCSwatch: UIView {

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        setup()
    }
    
    public init(color:Color,radius:CGFloat)
    {
        let diameter = 2.0*radius
        
        super.init(frame:CGRect(origin: CGPoint.zero, size: CGSize(width: diameter, height: diameter)) )
        setup()
        
        defer {
            self.color = color
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        self.isUserInteractionEnabled =  false
        
        self.radius = 0.5*bounds.size.width
    
        layer.cornerRadius = self.radius
        
        //border
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 0.5
        
        //shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowRadius = 5.0
    }
    
    override public func awakeFromNib() {
        setup()
    }
    
    override public func prepareForInterfaceBuilder() {
        setup()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    //MARK:- Instectabeles
    
    @IBInspectable
    var radius:CGFloat = 0.0 {
        didSet {
            let position = center
            frame = CGRect.square(center:CGPoint(x: radius, y: radius), with:2.0*radius)
            center = position
            layer.cornerRadius = radius
        }
    }
    
    @IBInspectable var iColor:UIColor {
        get {
            return color.uiColor
        }
        set {
            color = newValue
        }
    }
    
       //MARK:- Color
    
    //var  channel:ColorChannel = .red
    
    public var color:Color = UIColor.magenta {
        didSet {
            self.backgroundColor = color.uiColor
            setNeedsDisplay()
        }
    }

    
    

}
