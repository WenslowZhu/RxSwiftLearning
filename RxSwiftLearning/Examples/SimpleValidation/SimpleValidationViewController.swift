//
//  SimpleValidationViewController.swift
//  RxSwiftLearning
//
//  Created by apple on 2018/2/27.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate let minimalUsernameLength = 5
fileprivate let minimalPasswordLength = 5

class SimpleValidationViewController: RxViewController {

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    @IBOutlet weak var doSomethingOutlet: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setOutlet()
    }

    private func setOutlet() {

        usernameValidationOutlet.text = "Username has to be at least \(minimalUsernameLength) characters"
        passwordValidationOutlet.text = "Password has to be at least \(minimalPasswordLength) characters"

        //用户名是否有效
        let userNameValidation = usernameOutlet.rx.text.orEmpty
            .map{ $0.count >= minimalUsernameLength }
            .share()

        //密码是否有效
        let passwordValidation = passwordOutlet.rx.text.orEmpty
            .map{ $0.count >= minimalUsernameLength }
            .share()

        let everythingValidation = Observable.combineLatest(
            userNameValidation,
            passwordValidation
            ){$0 && $1}
            .share()

        userNameValidation
            .bind(to: usernameValidationOutlet.rx.isHidden)
            .disposed(by: disposeBag)

        userNameValidation
            .bind(to: passwordOutlet.rx.isEnabled)
            .disposed(by: disposeBag)

        passwordValidation
            .bind(to: passwordValidationOutlet.rx.isHidden)
            .disposed(by: disposeBag)

        everythingValidation
            .bind(to: doSomethingOutlet.rx.isEnabled)
            .disposed(by: disposeBag)

        //点击按钮事件
        doSomethingOutlet.rx.tap
            .subscribe { [weak self] _ in
            self?.showAlert()
        }.disposed(by: disposeBag)
    }

    private func showAlert(){
        let ac = UIAlertController(title: "Validate Success", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}
