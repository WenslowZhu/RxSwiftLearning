//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

example(of: "toArray") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "B", "C")
        // 2
        .toArray()
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
}

example(of: "map") {
    let disposeBag = DisposeBag()
    
    // 1
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    // 2
    Observable<NSNumber>.of(123, 4, 56)
        // 3
        .map{formatter.string(from: $0) ?? ""}
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
}

example(of: "enumerated and map") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
        // 2
        .enumerated()
        // 3
        .map({ (index, integer) -> Int in
            return index > 2 ? integer * 2 : integer
        })
        // 4
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
}

struct Student {
    var score: BehaviorSubject<Int>
}

example(of: "flatMap") {
    let disposeBag = DisposeBag()
    
    // 1
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    // 2
    let student = PublishSubject<Student>()
    
    // 3
    student
        .flatMap{$0.score}
        // 4
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
    
    student.onNext(ryan)
    ryan.score.onNext(85)
    
    student.onNext(charlotte)
    charlotte.score.onNext(95)
    charlotte.score.onNext(100)
}

example(of: "flatMapLatest") {
    let disposeBag = DisposeBag()
    
    // 1
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    // 2
    let student = PublishSubject<Student>()
    
    // 3
    student
        .flatMapLatest{$0.score}
        // 4
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
    
    student.onNext(ryan)
    ryan.score.onNext(85)
    
    student.onNext(charlotte)
    
    ryan.score.onNext(95)
    
    charlotte.score.onNext(100)
}

example(of: "materialize and ematerialize") {
    // 1
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()
    
    // 2
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 100))
    
    let student = BehaviorSubject(value: ryan)
    
    let studentScore = student.flatMapLatest{$0.score.materialize()}
    
    studentScore.subscribe(onNext: {print($0)}).disposed(by: disposeBag)
    
    ryan.score.onNext(85)
    ryan.score.onError(MyError.anError)
    ryan.score.onNext(90)
    
    student.onNext(charlotte)
    
    studentScore
        .filter{
        guard $0.error == nil else {
            print($0.error!)
            return false
        }
        return true
    }
        .dematerialize()
        .subscribe(onNext: {print($0)}).disposed(by: disposeBag)
}

// Challenges
example(of: "Challenge 1") {
    
    let disposeBag = DisposeBag()
    
    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]
    
    // 将手机键盘的文字转成数字
    let convert: (String) -> UInt? = { value in
        if let number = UInt(value), number < 10 {
            return number
        }
        
        let keyMap: [String: UInt] = [
            "abc": 2, "def": 3, "ghi": 4,
            "jkl": 5, "mno": 6, "pqrs": 7,
            "tuv": 8, "wxyz": 9
        ]
            
        let converted = keyMap
            .filter{$0.key.contains(value.lowercased())}
            .map{$0.value}
            .first
        
        return converted
    }
    
    // 构建格式化的号码
    let format: ([UInt]) -> String = {
        var phone = $0.map(String.init).joined()
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3
        ))
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7
        ))
        
        return phone
    }
    
    let dial: (String) -> String = {
        if let contact = contacts[$0] {
            return "Dialing \(contact) (\($0))..."
        } else {
            return "Contact not found"
        }
    }
    
    // Add your code here
    let input = Variable<String>("")
    
    input.asObservable()
        // 将文字装成数字
        .map{convert($0)}
        // 去除nil
        .flatMap{$0 == nil ? Observable.empty() : Observable.just($0!)}
        // 跳过前面的0
        .skipWhile{$0 == 0}
        // 只取10位
        .take(10)
        .toArray()
        // 转成电话格式
        .map{format($0)}
        // 查找联系人
        .map{dial($0)}
        .subscribe(onNext: {print($0)}).disposed(by: disposeBag)
    
    
    input.value = ""
    input.value = "0"
    input.value = "408"
    
    input.value = "6"
    input.value = ""
    input.value = "0"
    input.value = "3"
    
    "JKL1A1B".forEach {
        input.value = "\($0)"
    }
    
    input.value = "9"
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
