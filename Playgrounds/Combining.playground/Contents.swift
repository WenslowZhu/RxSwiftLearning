//: Please build the scheme 'RxSwiftPlayground' first

import RxSwift
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

example(of: "startWith") {
    // 1
    let number = Observable.of(2, 3, 4)
    
    // 2
    let observable = number.startWith(1)
    observable.subscribe(onNext: { (value) in
        print(value)
    })
}

example(of: "Observable.concat") {
    // 1
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)
    
    // 2
    let observable = Observable.concat([first, second])
    
    observable.subscribe(onNext: {print($0)})
}

example(of: "concat") {
    let germanCities = Observable.of("Berlin", "Munich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valenica")
    
    let observable = germanCities.concat(spanishCities)
    observable.subscribe(onNext: {print($0)})
}

example(of: "concatMap") {
    // 1
    let sequence = [
        "Germany": Observable.of("Berlin", "Munich", "Frankfurt"),
        "Spain": Observable.of("Madrid", "Barcelona", "Valenica")
    ]
    
    // 2
    let observable = Observable.of("Germany", "Spain").concatMap({ (country) -> Observable<String> in
        return sequence[country] ?? .empty()
    })
    
    // 3
    _ = observable.subscribe(onNext: {print($0)})
}
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
