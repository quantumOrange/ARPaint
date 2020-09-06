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
import UIKit

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
    drawPoints:Observable<[SIMD3<Float>]>,
    viewTap:Observable<UITapGestureRecognizer>,
    model:PaintModel
) ->
   (contolColor:Observable<Color>,
    paintPoints:Observable<[PointVertex]>,
    colorContolVisable:Observable<Bool>)

{
   
    let voidViewTaps = viewTap.map { _ in return () }
    let alltaps = Observable.of(voidViewTaps,swatchTapped).merge()
    
    let visable =  alltaps
                        .scan(false, accumulator: toggle)
                        .startWith(false)
    
    let controlColor = colorChanged
    
    let paintPoints:Observable<[PointVertex]> = Observable.zip(drawPoints,
                                     drawPoints.withLatestFrom(colorChanged),
                                     drawPoints.withLatestFrom(model.hardness),
                                     drawPoints.withLatestFrom(model.scatter),
                                     drawPoints.withLatestFrom(model.size)) {
        points , color , hardness, scatter, size in
        points.map { point in
            
            var newPoint = point
            
            if(scatter>0.01){
                newPoint += scatter*size*randomVector()
            }
            
            return PointVertex(position:newPoint,color:color.rgb.simd, size:size, hardness:hardness)
            
        }
    }
    
    return (contolColor:controlColor,
            paintPoints:paintPoints,
            colorContolVisable:visable)
   
}

func toggle(_ value:Bool,_ void:()) -> Bool {
    return !value
}
