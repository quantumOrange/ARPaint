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
//impot simd

func paintViewModel(
    colorChanged:Observable<Color>,
   // opacityTapped:Observable<Color>,
    swatchTapped:Observable<()>
) ->
   (contolColor:Observable<Color>,
    paintColor:Observable<float4>,
   // opacityColor:Observable<Color>,
    colorContolVisable:Observable<Bool>)

{
   
    let visable =  swatchTapped
                        .scan(false, accumulator: toggle)
                        .startWith(false)
    
    let paintColor = colorChanged.share()
        .map {
            $0.rgb.simd
        }
    
    let controlColor = colorChanged
    
    return (contolColor:controlColor,
            paintColor:paintColor,
            colorContolVisable:visable)
   
}

func toggle(_ value:Bool,_ void:()) -> Bool {
    return !value
}
