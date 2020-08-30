//
//  ColorControl+rx.swift
//  ARPaint
//
//  Created by David Crooks on 01/03/2019.
//  Copyright © 2019 David Crooks. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import DCColor

extension Reactive where Base: DCColorControl {

    // Reactive wrapper for `color` property.
    var color: ControlProperty<Color> {
        return controlProperty(editingEvents: .valueChanged,
                               getter: { colorControl in
                                    colorControl.color
                                },
                               setter: { colorControl, color in
                                    colorControl.color = color
                                })
    }
    
}

extension Reactive where Base: DCSwatchButton {

    // Reactive wrapper for `color` property.
    var color: ControlProperty<Color> {
        return controlProperty(editingEvents: .valueChanged,
                               getter: { colorControl in
                                    colorControl.color
                                },
                               setter: { colorControl, color in
                                    colorControl.color = color
                                })
    }
    
}
