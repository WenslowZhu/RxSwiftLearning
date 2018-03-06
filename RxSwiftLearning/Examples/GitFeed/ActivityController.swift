/*
 * Copyright (c) 2016-present Razeware LLC
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
import Kingfisher

func cachedFiledURL(_ fileName: String) -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first!.appendingPathComponent(fileName)
}

fileprivate let lastModifiedKey = "Last-Modified"

class ActivityController: UITableViewController {

  private let repo = "ReactiveX/RxSwift"

  private let events = Variable<[Event]>([])
  private let bag = DisposeBag()
    private let eventsFileURL = cachedFiledURL("events.plist")
    private let modifiedFileURL = cachedFiledURL("modified.txt")
    private let lastModified = Variable<NSString?>(nil)
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    title = repo

    self.refreshControl = UIRefreshControl()
    let refreshControl = self.refreshControl!

    refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
    refreshControl.tintColor = UIColor.darkGray
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

    fetchCacheData()
    checkLastModify()
    refresh()
  }

  @objc func refresh() {
    DispatchQueue.global(qos: .background).async { [weak self] in
      guard let strongSelf = self else { return }
//      strongSelf.fetchEvents(repo: strongSelf.repo)
        strongSelf.fetchSwiftEvents()
    }
  }

  func fetchEvents(repo: String) {
    let response = Observable.from([repo])
        .map{URL(string: "https://api.github.com/repos/\($0)/events")!}
        .map{ [weak self](url) -> URLRequest in
            var request = URLRequest(url: url)
            if let modifiedHeader = self?.lastModified.value {
                request.addValue(modifiedHeader as String, forHTTPHeaderField: lastModifiedKey)
            }
            return request
        }
        .flatMap{URLSession.shared.rx.response(request: $0)}
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
        .observeOn(MainScheduler.asyncInstance)
        .share(replay: 1, scope: .whileConnected)
    
    response
        .filter{200..<300 ~= $0.response.statusCode}
        .map { (_, data) -> [[String: Any]] in
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []), let result = jsonObject as? [[String: Any]] else {
                return []
            }
            return result
        }
        .filter{!$0.isEmpty}
        // 去除nil元素
        .map{$0.flatMap(Event.init)}
        .subscribe(onNext: { [weak self] (events) in
            self?.processEvents(events)
        }).disposed(by: bag)
    
    response
        .filter{200..<400 ~= $0.response.statusCode}
        .flatMap { (response, _) -> Observable<NSString> in
            guard let value = response.allHeaderFields[lastModifiedKey] as? NSString else {
                return Observable.empty()
            }
            return Observable.just(value)
        }
        .subscribe(onNext: { [weak self](modifiedHeader) in
            self?.lastModified.value = modifiedHeader
            do {
                try modifiedHeader.write(to: (self?.modifiedFileURL)!, atomically: true, encoding: String.Encoding.utf8.rawValue)
            }catch{}
        }).disposed(by: bag)
  }

    private func processEvents(_ newEvent: [Event]) {
        // 只取前50个
        var updatedEvent = newEvent + events.value
        if updatedEvent.count > 50 {
            updatedEvent = Array<Event>(updatedEvent.prefix(upTo: 50))
        }
        
        events.value = updatedEvent
        tableView.reloadData()
        refreshControl?.endRefreshing()
        
        DispatchQueue.global(qos: .default).async {
            let eventsArray = updatedEvent.map{$0.dictionary} as NSArray
            eventsArray.write(to: self.eventsFileURL, atomically: true)
        }
    }
    
    private func fetchCacheData() {
        DispatchQueue.global(qos: .default).async {
            let eventsArray = (NSArray(contentsOf: self.eventsFileURL) as? [[String: Any]]) ?? []
            self.events.value = eventsArray.flatMap(Event.init)
        }
    }
    
    private func checkLastModify() {
        do {
            lastModified.value = try NSString(contentsOf: modifiedFileURL, usedEncoding: nil)
        }catch{}
    }

    
    private func fetchSwiftEvents() {
        let response = Observable.from(["https://api.github.com/search/repositories?q=language:swift&per_page=5"])
            .map{URL(string: $0)!}
            .map{URLRequest(url: $0)}
            .flatMap{URLSession.shared.rx.response(request: $0)}
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .share()
        
        let searchReponse = response
            .filter{200..<400 ~= $0.response.statusCode}
            .map { (_, data) -> [String: Any] in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []), let result = jsonObject as? [String: Any] else {
                    return [:]
                }
                return result
            }
            .filter{!$0.isEmpty}
            .flatMap { (result) -> Observable<String> in
                return Observable<String>.create({ (observer) -> Disposable in
                    if let items = result["items"] as? [[String: Any]] {
                        items.forEach({ (item) in
                            if let fullName = item["full_name"] as? String {
                                observer.onNext(fullName)
                            }
                        })
                    }
                    observer.onCompleted()
                    return Disposables.create()
                })
            }
            .map{URL(string: "https://api.github.com/repos/\($0)/events?per_page=5")!}
            .map{URLRequest.init(url: $0)}
            .flatMap{URLSession.shared.rx.response(request: $0)}
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .share(replay: 1, scope: .whileConnected)
        
        searchReponse
            .filter{200..<300 ~= $0.response.statusCode}
            .map { (_, data) -> [[String: Any]] in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []), let result = jsonObject as? [[String: Any]] else {
                    return []
                }
                return result
            }
            .filter{!$0.isEmpty}
            // 去除nil元素
            .map{$0.flatMap(Event.init)}
            .subscribe(onNext: { [weak self] (events) in
                self?.processEvents(events)
            }).disposed(by: bag)
    }
    
  // MARK: - Table Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return events.value.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let event = events.value[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
    cell.textLabel?.text = event.name
    cell.detailTextLabel?.text = event.repo + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
    cell.imageView?.kf.setImage(with: event.imageUrl, placeholder: UIImage(named: "blank-avatar"))
    return cell
  }
}
