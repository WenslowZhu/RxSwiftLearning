//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

example(of: "ignoreElements") {
    // 1
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    // 2
    strikes
        .ignoreElements()
        .subscribe({ (_) in
            print("You're out!")
    }).disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onCompleted()
}

example(of: "elementAt") {
    // 1
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    // 2
    strikes
        .elementAt(2)
        .subscribe(onNext: { (string) in
            print(string)
        }).disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
}

example(of: "filter") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
        // 2
        .filter({ $0 % 2 == 0 })
        // 3
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
}

example(of: "skip") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "B", "C", "D", "E", "F")
        // 2
        .skip(3)
        .subscribe(onNext: {print($0)}).disposed(by: disposeBag)
}

example(of: "skipWhile") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(2, 2, 3, 4, 4)
        // 2
        .skipWhile{$0 % 2 == 0}
        .subscribe(onNext: {print($0)}).disposed(by: disposeBag)
}

example(of: "skipUntil") {
    let disposeBag = DisposeBag()
    
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2
    subject
        .skipUntil(trigger)
        .subscribe(onNext: {print($0)}).disposed(by: disposeBag)
    
    subject.onNext("A")
    subject.onNext("B")
    
    trigger.onNext("X")
    
    subject.onNext("C")
    subject.onNext("D")
}

example(of: "take") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
        // 2
        .take(3)
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
}

example(of: "takeWhile") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(2, 2, 4, 4, 6, 6)
        // 2
        .enumerated()
        // 3
        .takeWhile({ (index, integer) -> Bool in
            // 4
            integer % 2 == 0 && index < 3
        })
        // 5
        .map{ $0.element }
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
}

example(of: "takeUntil") {
    let disposeBag = DisposeBag()
    
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2
    subject
        .takeUntil(trigger)
        .subscribe(onNext: {print($0)}).disposed(by: disposeBag)
    
    // 3
    subject.onNext("1")
    subject.onNext("2")
    
    trigger.onNext("X")
    subject.onNext("3")
}

example(of: "distinctUntilChanged") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "A", "B", "B", "A")
        // 2
        .distinctUntilChanged()
        .subscribe(onNext: {print($0)}).disposed(by: disposeBag)
}

//example(of: "distinctUntilChanged(_:)") {
//    let disposeBag = DisposeBag()
//
//    // 1
//    let formatter = NumberFormatter()
//    formatter.numberStyle = .spellOut
//
//    // 2
//    Observable<NSNumber>.of(10, 100, 20, 200, 210, 310)
//        // 3
//        .distinctUntilChanged({ (a, b) -> Bool in
//            guard let aWords = formatter.string(from: a)?.components(separatedBy: " "), let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {return false}
//
//            var containsMatch = false
//
//            // 5
//            print("aWords", aWords)
//            print("bWords", bWords)
//            for aWord in aWords {
//                for bWord in bWords {
//                    if aWord == bWord {
//                        containsMatch = true
//                        break
//                    }
//                }
//            }
//            return containsMatch
//        }).subscribe(onNext: {print($0)}).disposed(by: disposeBag)
//}

//// Challenges
//example(of: "Challenge 1") {
//
//    let disposeBag = DisposeBag()
//
//    let contacts = [
//        "603-555-1212": "Florent",
//        "212-555-1212": "Junior",
//        "408-555-1212": "Marin",
//        "617-555-1212": "Scott"
//    ]
//
//    // 构建格式化的号码
//    func phoneNumber(from inputs: [Int]) -> String {
//        var phone = inputs.map(String.init).joined()
//
//        phone.insert("-", at: phone.index(
//            phone.startIndex,
//            offsetBy: 3)
//        )
//
//        phone.insert("-", at: phone.index(
//            phone.startIndex,
//            offsetBy: 7)
//        )
//
//        return phone
//    }
//
//    let input = PublishSubject<Int>()
//
//    // Add your code here
//    input
//        // 号码不能以0开头
//        .skipWhile{$0 == 0}
//        // 只能输入个位数数字
//        .filter{$0 < 10 && $0 > 0}
//        // 只取前10位输入
//        .take(10)
//        // 转换成Array
//        .toArray()
//        .subscribe(onNext: { (digitalArray) in
//            let phone = phoneNumber(from: digitalArray)
//            print("phone number", phone)
//            if let lookupName = contacts[phone]{
//                print("Found", lookupName)
//            } else {
//                print("Not found")
//            }
//        }).disposed(by: disposeBag)
//
//    input.onNext(0)
//    input.onNext(603)
//
//    input.onNext(2)
//    input.onNext(1)
//
//    // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
//    input.onNext(2)
//
//    "5551212".forEach {
//        if let number = (Int("\($0)")) {
//            input.onNext(number)
//        }
//    }
//
//    input.onNext(9)
//}

// Test share

example(of: "share") {
    let disposeBag = DisposeBag()
    
    var start = 0
    func getStartNumber()->Int {
        start += 1
        return start
    }
    
    let numbers = Observable<Int>.create({ (observer) -> Disposable in
        let start = getStartNumber()
        observer.onNext(start)
        observer.onNext(start+1)
        observer.onNext(start+2)
        observer.onCompleted()
        return Disposables.create()
    }).share()
    
    numbers
        .subscribe(onNext: {print("element [\($0)]")}, onCompleted: {
        print("------------------")
    }).disposed(by: disposeBag)
    
    numbers
        .subscribe(onNext: {print("element [\($0)]")}, onCompleted: {
            print("------------------")
        }).disposed(by: disposeBag)
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
