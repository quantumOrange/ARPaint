//
//  DCSwatchButton.swift
//  DCColor
//
//  Created by David Crooks on 22/03/2017.
//  Copyright © 2017 David Crooks. All rights reserved.
//

import UIKit


@IBDesignable
public class DCSwatchButton: UIButton {
    
    public var color:Color {
        get {
            return swatch.color
        }
        set {
            swatch.color = newValue
        }
    }
    
    var radius:CGFloat = 20.0 {
        didSet {
            swatch.radius = radius
        }
    }
    
    private var swatch:DCSwatch!
    init(color:Color,radius:CGFloat)
    {
        super.init(frame:CGRect.square(center: CGPoint.zero, with:2.0*radius ))
        setup()
        
        defer {
            self.color = color
        }
    }
    
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
        
        swatch = DCSwatch(color:UIColor.yellow, radius:radius)
        swatch.center = bounds.center
        addSubview(swatch)
        
        isSetup = true
    }

}
