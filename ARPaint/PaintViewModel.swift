//
//  PaintViewModel.swift
//  ARPaint
//
//  Created by David Crooks on 01/03/2019.
//  Copyright © 2019 David Crooks. All rights reserved.
//
import DCColor
import Foundation
import RxSwift


func paintViewModel(
    colorChanged:Observable<Color>,
    swatchTapped:Observable<()>,
    drawPoints:Observable<[SIMD3<Float>]>
) ->
   (contolColor:Observable<Color>,
    paintPoints:Observable<[PointVertex]>,
    colorContolVisable:Observable<Bool>)

{
   
    let visable =  swatchTapped
                        .scan(false, accumulator: toggle)
                        .startWith(false)
    
    let controlColor = colorChanged
    
    let paintPoints = Observable.zip(drawPoints, drawPoints.withLatestFrom(colorChanged)) {
        points , color in
        points.map { point in
            PointVertex(position:point,color:color.rgb.simd, size:0.01, hardness:0.1)
            
        }
    }
    
    return (contolColor:controlColor,
            paintPoints:paintPoints,
            colorContolVisable:visable)
   
}

func toggle(_ value:Bool,_ void:()) -> Bool {
    return !value
}
