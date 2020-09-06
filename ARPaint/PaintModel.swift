//
//  Paramtere.swift
//  ARPaint
//
//  Created by David Crooks on 04/09/2020.
//  Copyright © 2020 David Crooks. All rights reserved.
//

import Foundation
import RxSwift
import DCColor

class PaintModel {
    var color:BehaviorSubject<Color> = BehaviorSubject(value: RGBColor(red:1.0))
    var hardness:BehaviorSubject<Float> = BehaviorSubject(value:0.2)
    var scatter:BehaviorSubject<Float> = BehaviorSubject(value:0.2)
    var size:BehaviorSubject<Float> = BehaviorSubject(value:0.01)
    var noise:BehaviorSubject<Bool> = BehaviorSubject(value:false)
}
