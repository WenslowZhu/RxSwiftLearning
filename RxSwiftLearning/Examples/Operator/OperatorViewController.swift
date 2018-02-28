//
//  OperatorViewController.swift
//  RxSwiftLearning
//
//  Created by Wenslow on 2018/2/28.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class OperatorViewController: RxViewController {

    @IBOutlet weak var filterOutlet: UITextView!
    @IBOutlet weak var mapOutlet: UITextView!
    @IBOutlet weak var zipOutlet: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        filterOperator()
        mapOperator()
        zipOperator()
    }

    private func filterOperator() {
        let rxTemperature = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(12)
            observer.onNext(22)
            observer.onNext(42)
            observer.onNext(45)
            observer.onNext(56)
            observer.onNext(78)
            observer.onNext(89)
            observer.onNext(90)
            observer.onNext(97)
            observer.onCompleted()
            return Disposables.create()
        }
        
        rxTemperature
            .filter { $0 >= 50 }
            .subscribe(onNext: { [weak self] (temperature) in
                if let oldString = self?.filterOutlet.text {
                    self?.filterOutlet.text = oldString + "--" + "\(temperature)"
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    private func mapOperator() {
        let rxTemperature = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(12)
            observer.onNext(22)
            observer.onNext(42)
            observer.onNext(45)
            observer.onNext(56)
            observer.onNext(78)
            observer.onNext(89)
            observer.onNext(90)
            observer.onNext(97)
            observer.onCompleted()
            return Disposables.create()
        }
        
        rxTemperature
            .map{"\($0)"}
            .subscribe(onNext: { [weak self] (newString) in
            if let oldString = self?.mapOutlet.text {
                self?.mapOutlet.text = oldString + "--" + newString
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    private func zipOperator() {
        let rxTemperature = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(12)
            observer.onNext(22)
            observer.onNext(42)
            observer.onNext(45)
            observer.onNext(56)
            observer.onNext(78)
            observer.onNext(89)
            observer.onNext(90)
            observer.onNext(97)
            observer.onCompleted()
            return Disposables.create()
        }
        
        let rxEmoji = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("🚙")
            observer.onNext("🚀")
            observer.onNext("🤷‍")
            observer.onNext("😄")
            observer.onNext("🙊")
            observer.onNext("🐌")
            observer.onNext("🍟")
            observer.onNext("🤾‍")
            observer.onNext("🔋")
            observer.onCompleted()
            return Disposables.create()
        }
        
        Observable
            .zip(rxTemperature, rxEmoji)
            .subscribe(onNext: { [weak self] (temperature, emoji) in
            if let oldString = self?.zipOutlet.text {
                self?.zipOutlet.text = oldString + "\(temperature)" + "-" + emoji + "\n"
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}
