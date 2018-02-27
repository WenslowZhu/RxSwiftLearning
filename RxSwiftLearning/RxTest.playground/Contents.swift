//: Playground - noun: a place where people can play

import RxSwift

var disposebag = DisposeBag()

func getRepo(_ repo: String)->Single<[String: Any]>{
    return Single<[String: Any]>.create(subscribe: { (single) -> Disposable in
        let url = URL(string: "https://api.github.com/repos/\(repo)")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            if let error = error {
                single(.error(error))
                return
            }

            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                let result = json as? [String: Any] else {
                    return
            }

            single(.success(result))
        })
        task.resume()

        return Disposables.create {
            task.cancel()
        }
    })
}

getRepo("ReactiveX/RxSwift").subscribe(onSuccess: { (json) in
    print("json: ", json)
}) { (error) in
    print("error: ", error)
}.disposed(by: disposebag)
