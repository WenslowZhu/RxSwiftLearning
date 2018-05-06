//: Please build the scheme 'RxSwiftPlayground' first
import UIKit
import RxSwift
import RxCocoa



// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
  static func make() -> TimelineView<E> {
    return TimelineView(width: 400, height: 100)
  }
  public func on(_ event: Event<E>) {
    switch event {
    case .next(let value):
      add(.Next(String(describing: value)))
    case .completed:
      add(.Completed())
    case .error(_):
      add(.Error())
    }
  }
}

// 每秒一个元素
let elementsPerSecond = 1
// 最多元素
let maxElements = 5
let replayedElements = 1
let replayDelay: TimeInterval = 3

let sourceObservable = Observable<Int>.create { (observer) -> Disposable in
    var value = 1
    
    let timer = DispatchSource.makeTimerSource(queue: .main)
    timer.setEventHandler(handler: {
        if value <= maxElements {
            observer.onNext(value)
            value += 1
        }
    })
    timer.schedule(deadline: .now(), repeating: 1.0 / Double(elementsPerSecond), leeway: .nanoseconds(0))
    timer.resume()
    
    return Disposables.create {
        timer.suspend()
    }
    }.replay(replayedElements)//缓存多少个元素

let sourceTimeline = TimelineView<Int>.make()
let replayedTimeline = TimelineView<Int>.make()

let stack = UIStackView.makeVertical([
    UILabel.makeTitle("replay"),
    UILabel.make("Emit \(elementsPerSecond) per second:"),
    sourceTimeline,
    UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
    replayedTimeline])

_ = sourceObservable.subscribe(sourceTimeline)

DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + replayDelay) {
    _ = sourceObservable.subscribe(replayedTimeline)
}

_ = sourceObservable.connect()

let hostView = setupHostView()
hostView.addSubview(stack)
hostView
/*:
 Copyright (c) 2014-2017 Razeware LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
