/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxCocoa

class CategoriesViewController: RxViewController {

  @IBOutlet var tableView: UITableView!
    
    var navigationbarActivityIndicatorOutlet: UIActivityIndicatorView!
    
    let categories = Variable<[EOCategory]>([])
    
    override func viewDidLoad() {
    super.viewDidLoad()

    startDownload()
    tableViewDelegate()
        
    categories
        .asDriver()
        .drive(tableView.rx.items(cellIdentifier: "categoryCell"), curriedArgument: {
        (index, category, cell) in
            cell.textLabel?.text = "\(category.name) (\(category.events.count))"
            cell.accessoryType = (!category.events.isEmpty ? .disclosureIndicator : .none)
    }).disposed(by: disposeBag)
    
        // 监听网络请求进度, 通知加载器的动画
//        categories
//            .asObservable()
//            .observeOn(MainScheduler.asyncInstance)
//            .subscribe(onNext: { [weak self] result in
//                if !result.isEmpty {
//                    self?.activityIndicatorOutlet.stopAnimating()
//                }
//            }, onError: { [weak self] (_) in
//            self?.activityIndicatorOutlet.stopAnimating()
//                }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

//    categories
//        .asObservable()
//        .subscribe(onNext:{ _ in
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//    }).disposed(by: disposeBag)
        
        // 导航栏的加载器
        navigationbarActivityIndicatorOutlet = UIActivityIndicatorView()
        navigationbarActivityIndicatorOutlet.color = UIColor.black
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationbarActivityIndicatorOutlet)
        navigationbarActivityIndicatorOutlet.startAnimating()
  }

  func startDownload() {
    let eoCategories = EONET.categories
    let downloadedEvents = eoCategories.flatMap { (categories) in
        return Observable.from(categories.map({ (category) in
            EONET.events(forLast: 360, category: category)
        }))
        }.merge(maxConcurrent: 2)
    
    let updatedCategories = eoCategories.flatMap { (categories) in
        downloadedEvents.scan(categories, accumulator: { (updated, events) in
            return updated.map { (category) in
                let eventsForCategory = EONET.filteredEvents(events: events, forCategory: category)
                if !eventsForCategory.isEmpty {
                    var cat = category
                    cat.events = cat.events + eventsForCategory
                    return cat
                }
                return category
            }
        })
    }
    
    // eoCategories 发出一个元素之后就completed了, 之后updatedCategories会被订阅
    eoCategories
        .concat(updatedCategories)
        .bind(to: categories)
        .disposed(by: disposeBag)
    
    // 监听网络请求进度, 通知加载器的动画
    updatedCategories
        .observeOn(MainScheduler.asyncInstance)
        .subscribe(onNext: nil, onError: { [weak self] (_) in
                self?.navigationbarActivityIndicatorOutlet.stopAnimating()
            }, onCompleted: { [weak self]  in
                self?.navigationbarActivityIndicatorOutlet.stopAnimating()
            }, onDisposed: nil).disposed(by: disposeBag)
    }
  
    private func tableViewDelegate() {
//        tableView.rx.modelSelected(EOCategory.self).subscribe(onNext: { [weak self] (category) in
//            guard
//                !category.events.isEmpty,
//                let eventsController = self?.storyboard?.instantiateViewController(withIdentifier: "events") as? EventsViewController else { return }
//
//            eventsController.title = category.name
//            eventsController.events.value = category.events
//            self?.navigationController?.pushViewController(eventsController, animated: true)
//        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            guard
                let events = self?.categories.value[indexPath.row].events,
                let eventsController = self?.storyboard?.instantiateViewController(withIdentifier: "events") as? EventsViewController else {return}
            eventsController.title = self?.categories.value[indexPath.row].name
            eventsController.events.value = events
            self?.navigationController?.pushViewController(eventsController, animated: true)
            self?.tableView.deselectRow(at: indexPath, animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
  // MARK: UITableViewDataSource
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return categories.value.count
//  }
//  
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
//    let category = categories.value[indexPath.row]
//    cell.textLabel?.text = category.name
//    cell.detailTextLabel?.text = category.description
//    return cell
//  }
  
}

