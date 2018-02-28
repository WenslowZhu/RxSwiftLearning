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

class SingleObservableViewController: RxViewController {

    @IBOutlet weak var repoOutlet: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        getRepo("ReactiveX/RxSwift")
            .subscribe(onSuccess: { [weak self] (json) in
               self?.repoOutlet.text = json.description
            }) { [weak self] (error) in
                self?.repoOutlet.text = error.localizedDescription
            }.disposed(by: disposeBag)
    }

    private func getRepo(_ repo: String)->Single<[String: Any]>{
        return Single<[String: Any]>.create(subscribe: { (single) -> Disposable in
            let url = URL(string: "https://api.github.com/repos/\(repo)")!
            let task = URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, _, error) in
                
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
                
                if let error = error {
                    single(.error(error))
                    return
                }

                guard
                    let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                    let result = json as? [String: Any] else {
                        self?.present(AlertHelper.commonAlert(title: "No Data"), animated: true, completion: nil)
                        return
                }

                single(.success(result))
            })
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }).observeOn(MainScheduler.asyncInstance)
    }

}
