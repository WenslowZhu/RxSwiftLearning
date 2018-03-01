//
//  UITestViewController.swift
//  RxSwiftLearning
//
//  Created by Wenslow on 2018/3/1.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UITestViewController: RxViewController {

    @IBOutlet weak var switcher: UISwitch!
    @IBOutlet weak var switchStateOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switchBinder()
    }

    private func switchBinder() {
        switcher.rx.isOn
            .map{ (value) -> String in
            return "Switch is " + (value == true ? "On" : "Off")
            }.bind { [weak self] (value) in
                self?.switchStateOutlet.text = value
            }.disposed(by: disposeBag)
    }
}
