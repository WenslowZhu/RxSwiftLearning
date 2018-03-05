//
//  UIViewController+rx.swift
//  RxSwiftLearning
//
//  Created by Wenslow on 2018/3/5.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension UIViewController {
    func alert(_ title: String, description: String? = nil) -> Completable {
        return Completable.create(subscribe: { [weak self] (completed) -> Disposable in
            let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
                completed(.completed)
            }))
            self?.present(alert, animated: true, completion: nil)
            return Disposables.create {
                self?.dismiss(animated: true, completion: nil)
            }
        })
    }
}
