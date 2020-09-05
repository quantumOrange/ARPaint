//
//  SlidersViewController.swift
//  ARPaint
//
//  Created by David Crooks on 05/09/2020.
//  Copyright © 2020 David Crooks. All rights reserved.
//

import UIKit
import RxSwift

class SlidersViewController: UIViewController {

    @IBOutlet weak var hardness: UISlider!
    
    @IBOutlet weak var scatter: UISlider!
    
    @IBOutlet weak var dismiss: UIButton!
    
    @IBOutlet weak var size: UISlider!
    
    @IBOutlet weak var noise: UISwitch!
    
    let bag = DisposeBag()
    
    var model:PaintModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        model
            .hardness
            .bind(to: hardness.rx.value)
            .disposed(by: bag)

        model
            .scatter
            .bind(to: scatter.rx.value)
            .disposed(by: bag)

        model
            .size
            .bind(to:size.rx.value)
            .disposed(by: bag)

        model
            .noise
            .bind(to:noise.rx.isOn)
            .disposed(by: bag)
        
        dismiss
            .rx
            .tap
            .asObservable()
            .subscribe(onNext:{ _ in self.dismiss(animated: true, completion: {})})
            .disposed(by: bag)
        
        hardness
            .rx
            .value
            .asObservable()
            .bind(to: model.hardness)
            .disposed(by: bag)
        
        scatter
            .rx
            .value
            .asObservable()
            .bind(to: model.scatter)
            .disposed(by: bag)
        
        noise
            .rx
            .isOn
            .asObservable()
            .bind(to: model.noise)
            .disposed(by: bag)
        
    }
    
}
