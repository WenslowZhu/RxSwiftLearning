//
//  ObservableAndObserverViewController.swift
//  RxSwiftLearning
//
//  Created by Wenslow on 2018/2/28.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ObservableAndObserverViewController: RxViewController {

    @IBOutlet weak var asyncSubjectTextViewOutlet: UITextView!
    @IBOutlet weak var publicSubjectTextViewOutlet: UITextView!
    @IBOutlet weak var replaySubjectTextViewOutlet: UITextView!
    @IBOutlet weak var behaviorSubjectTextViewOutlet: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testAsyncSubject()
        testPublicSubject()
        testReplaySubject()
        testBehaviorSubject()
    }
    
    private func testAsyncSubject() {
        let asyncSubject = AsyncSubject<String>()
        
        asyncSubject.subscribe({
            print("Async Subject: 1 Event", $0)
        }).disposed(by: disposeBag)
        
        asyncSubject.bind { [weak self] (newString) in
            if let oldString = self?.asyncSubjectTextViewOutlet.text {
                self?.asyncSubjectTextViewOutlet.text = oldString + "Async Subject: 1 Event " + newString
            }
        }.disposed(by: disposeBag)
        
        asyncSubject.onNext("🐶")
        asyncSubject.onNext("🐱")
        asyncSubject.onNext("🐭")
        asyncSubject.onCompleted()
    }
    
    private func testPublicSubject() {
        let subject = PublishSubject<String>()
        
        subject.subscribe({
            print("Public Subject: 1 Event", $0)
        }).disposed(by: disposeBag)
        
        subject.bind { [weak self] (newString) in
            if let oldString = self?.publicSubjectTextViewOutlet.text {
                self?.publicSubjectTextViewOutlet.text = oldString + "Public Subject: 1 Event " + newString + "\n"
            }
            }.disposed(by: disposeBag)
        
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        //第二次订阅之前的内容不会发送给观察者
        
        subject.subscribe({
            print("Public Subject: 2 Event", $0)
        }).disposed(by: disposeBag)
        
        subject.bind { [weak self] (newString) in
            if let oldString = self?.publicSubjectTextViewOutlet.text {
                self?.publicSubjectTextViewOutlet.text = oldString + "Public Subject: 2 Event " + newString + "\n"
            }
            }.disposed(by: disposeBag)
        
        subject.onNext("A")
        subject.onNext("B")
        subject.onCompleted()
    }
    
    private func testReplaySubject() {
        let subject = ReplaySubject<String>.create(bufferSize: 1)//缓存多少订阅前的元素
        
        subject.subscribe({
            print("Replay Subject: 1 Event", $0)
        }).disposed(by: disposeBag)
        
        subject.bind { [weak self] (newString) in
            if let oldString = self?.replaySubjectTextViewOutlet.text {
                self?.replaySubjectTextViewOutlet.text = oldString + "Replay Subject: 1 Event " + newString + "\n"
            }
            }.disposed(by: disposeBag)
        
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        subject.subscribe({
            print("Replay Subject: 2 Event", $0)
        }).disposed(by: disposeBag)
        
        subject.bind { [weak self] (newString) in
            if let oldString = self?.replaySubjectTextViewOutlet.text {
                self?.replaySubjectTextViewOutlet.text = oldString + "Replay Subject: 2 Event " + newString + "\n"
            }
            }.disposed(by: disposeBag)
        
        subject.onNext("A")
        subject.onNext("B")
        subject.onCompleted()
    }
    
    private func testBehaviorSubject() {
        let subject = BehaviorSubject(value: "🍠")
        
        subject.subscribe({
            print("Behavior Subject: 1 Event", $0)
        }).disposed(by: disposeBag)
        
        subject.bind { [weak self] (newString) in
            if let oldString = self?.behaviorSubjectTextViewOutlet.text {
                self?.behaviorSubjectTextViewOutlet.text = oldString + "Behavior Subject: 1 Event " + newString + "\n"
            }
            }.disposed(by: disposeBag)
        
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        subject.subscribe({
            print("Behavior Subject: 2 Event", $0)
        }).disposed(by: disposeBag)
        
        subject.bind { [weak self] (newString) in
            if let oldString = self?.behaviorSubjectTextViewOutlet.text {
                self?.behaviorSubjectTextViewOutlet.text = oldString + "Behavior Subject: 2 Event " + newString + "\n"
            }
            }.disposed(by: disposeBag)
        
        subject.onNext("A")
        subject.onNext("B")
        
        subject.subscribe({
            print("Behavior Subject: 3 Event", $0)
        }).disposed(by: disposeBag)
        
        subject.bind { [weak self] (newString) in
            if let oldString = self?.behaviorSubjectTextViewOutlet.text {
                self?.behaviorSubjectTextViewOutlet.text = oldString + "Behavior Subject: 3 Event " + newString + "\n"
            }
            }.disposed(by: disposeBag)
        
        subject.onNext("🍐")
        subject.onNext("🍊")
        subject.onCompleted()
    }
}
