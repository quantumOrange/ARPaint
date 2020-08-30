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


/*
 Here I'm using a pure function of observables in place of the MVVM view model.
 See this talk be Stephen Celis at Functional Swift:
 https://www.youtube.com/watch?v=uTLG_LgjWGA
 Also this article covers the same idea:
 https://medium.com/grailed-engineering/modeling-your-view-models-as-functions-65b58525717f
*/

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
