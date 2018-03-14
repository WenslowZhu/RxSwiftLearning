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

example(of: "merge") {
    // 1
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    // 2
    let source = Observable.of(left.asObserver(), right.asObserver())
    
    // 3
    let observable = source.merge()
    let disposable = observable.subscribe(onNext: {print($0)})
    
    // 4
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valenica"]
    repeat {
        if arc4random_uniform(2) == 0 {
            if !leftValues.isEmpty {
                left.onNext("Left: " + leftValues.removeFirst())
            }
        } else if !rightValues.isEmpty {
            right.onNext("Right: " + rightValues.removeFirst())
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
    
    // 5
    disposable.dispose()
}

example(of: "combineLatest") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    // 1
    let observable = Observable.combineLatest(left, right, resultSelector: { (lastLeft, lastRight) in
        "\(lastLeft) \(lastRight)"
    })
    let disposable = observable.subscribe(onNext:{print($0)})
    
    // 2
    print("> Sending a value to Left")
    left.onNext("Hello,")
    print("> Sending a Value to Right")
    right.onNext("world")
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    print("> Sending another value to Left")
    left.onNext("Have a good day,")
    
    disposable.dispose()
}

example(of: "zip") {
    enum Weather {
        case cloudy
        case sunny
    }
    
    let left: Observable<Weather> = Observable.of(Weather.sunny, Weather.cloudy, Weather.cloudy, Weather.sunny)
    let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
    
    let observable = Observable.zip(left, right, resultSelector: { (weather, city) in
        return "It's \(weather) in \(city)"
    })
    observable.subscribe(onNext: {print($0)})
}

example(of: "withLatestFrom") {
    // 1
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    // 2
    let observable = button.withLatestFrom(textField)
//    let observable = textField.sample(button)
    _ = observable.subscribe(onNext: {print($0)})
    
    // 3
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    button.onNext(())
    button.onNext(())
}

example(of: "amb") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    // 1
    let observable = left.amb(right)
    let disposable = observable.subscribe(onNext: {print($0)})
    
    // 2
    left.onNext("Lisbon")
    right.onNext("Copenhagen")
    left.onNext("London")
    left.onNext("Madrid")
    right.onNext("Vienna")
    
    disposable.dispose()
}

example(of: "switchLatest") {
    // 1
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    
    // 2
    let observable = source.switchLatest()
    let disposable = observable.subscribe(onNext: {print($0)})
    
    // 3
    source.onNext(one)
    one.onNext("Some text from sequene one")
    two.onNext("Some text from sequence tow")
    
    source.onNext(two)
    two.onNext("More text from sequence two")
    one.onNext("and also from sequence one")
    
    source.onNext(three)
    two.onNext("Why don't you see me?")
    one.onNext("I'm alone, help me")
    three.onNext("Hey it's three. I win")
    
    source.onNext(one)
    one.onNext("Nope. It's me, one!")
    
    disposable.dispose()
}

example(of: "reduce") {
    let source = Observable.of(1, 3, 5, 7, 9)
    
    // 1
    let observable = source.reduce(0, accumulator: +)
//    let observable = source.reduce(0, accumulator: { (summary, newValue) in
//        return summary + newValue
//    })
    observable.subscribe(onNext: {print($0)})
}

example(of: "scan") {
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.scan(0, accumulator: +)
    observable.subscribe(onNext: {print($0)})
}

// Challenges
example(of: "Challenges using zip") {
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable1 = source.asObservable()
    let observable2 = source.scan(0, accumulator: +)
    
    let combinedObservable = Observable.zip(observable1, observable2, resultSelector: { (value1, value2) in
        return "current: \(value1), total: \(value2)"
    })
    combinedObservable.subscribe(onNext: {print($0)})
}

example(of: "Challenges using scan and tuple") {
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.scan((0, 0), accumulator: { tuple, newValue in
        return (newValue, tuple.1 + newValue)
    })
    
    observable.subscribe(onNext: {print("currentValue: \($0.0), totalValue: \($0.1)")})
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
