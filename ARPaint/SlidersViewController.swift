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
    
    let bag = DisposeBag()
    
    var model:PaintModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        model.hardness.bind(to: hardness.rx.value)
        model.scatter.bind(to: scatter.rx.value)
        model.size.bind(to:size.rx.value)
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
