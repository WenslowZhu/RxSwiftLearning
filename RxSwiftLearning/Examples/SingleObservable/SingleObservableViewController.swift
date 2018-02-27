//
//  SingleObservableViewController.swift
//  RxSwiftLearning
//
//  Created by apple on 2018/2/27.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SingleObservableViewController: UIViewController {

    @IBOutlet weak var repoOutlet: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var disposebag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        getRepo("ReactiveX/RxSwift")
            .subscribe(onSuccess: { [weak self] (json) in
                DispatchQueue.main.async {
                    self?.repoOutlet.text = json.description
                    self?.activityIndicator.stopAnimating()
                }
            }) { [weak self] (error) in
                DispatchQueue.main.async {
                    self?.repoOutlet.text = error.localizedDescription
                    self?.activityIndicator.stopAnimating()
                }
            }.disposed(by: disposebag)
    }

    private func getRepo(_ repo: String)->Single<[String: Any]>{
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

}
