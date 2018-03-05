//
//  DriverObservableViewController.swift
//  RxSwiftLearning
//
//  Created by Wenslow on 2018/2/28.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

fileprivate let wikiSearchAPI = "https://en.wikipedia.org/w/api.php?action=opensearch&search="

class DriverObservableViewController: RxViewController {

    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewOutlet.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //声明序列
        let results = searchBarOutlet.rx.text.orEmpty
            .asDriver()
            .throttle(1)//设置检测间隔, 默认在主线程执行所有操作
            .distinctUntilChanged()//将新的值和旧的值进行比较
            .flatMapLatest { [weak self] (query) in
                (self?.searchWikipedia(query: query)
                .retry(3)
                .asDriver(onErrorJustReturn: []))!//出错时返回
        }
        
        results
            .map{"\($0.count)"}
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        results.drive(tableViewOutlet.rx.items(cellIdentifier: "DriverCell"), curriedArgument: {
            (_, result, cell) in
            cell.textLabel?.text = result
        }).disposed(by: disposeBag)
    }
    
    private func searchWikipedia(query: String) ->Maybe<[String]>{
        let urlQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let url = URL(string: wikiSearchAPI + urlQuery)!
        
        return Maybe.create(subscribe: { (maybe) in
            let task = URLSession.shared.dataTask(with: url, completionHandler: {(data, _, error) in
                if let error = error {
                    maybe(.error(error))
                    return
                }
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [Any], let results = json[1] as? [String]{
                    maybe(.success(results))
                    return
                }
                maybe(.completed)
            })
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        })
    }
}
