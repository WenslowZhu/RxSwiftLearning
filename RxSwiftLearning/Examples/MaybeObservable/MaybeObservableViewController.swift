//
//  MaybeObservableViewController.swift
//  RxSwiftLearning
//
//  Created by Wenslow on 2018/2/28.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

fileprivate let imageURLString = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnLvbiWJDefGBB7m1P8CemebZN2dn7yKAQ2yF4StOrjiQh76kt"

class MaybeObservableViewController: RxViewController {
    
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // 使用NSCache
    private var cache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cacheImage()
            .subscribe(onSuccess: { [weak self] (image) in
                self?.imageOutlet.image = image
        }, onError: { (error) in
            print(error)
        }) {[weak self] in
            self?.present(AlertHelper.commonAlert(title: "No Image Cached"), animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
    
    private func cacheImage() -> Maybe<UIImage>{
        return Maybe<UIImage>.create(subscribe: { (maybe) in
            let downloadTask = URLSession.shared.dataTask(with: URL(string: imageURLString)!, completionHandler: { [weak self] (data, response, error) in
                
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
                
                if let error = error {
                    maybe(.error(error))
                    return
                }
                // 获得图片并且保存 主线程返回
                if let data = data {
                    maybe(.success(UIImage(data: data)!))
                    self?.cache.setObject(data as AnyObject, forKey: imageURLString as AnyObject)
                    return
                }
                maybe(.completed)
            })
            downloadTask.resume()
            return Disposables.create {
                downloadTask.cancel()
            }
        }).observeOn(MainScheduler.asyncInstance)
    }
}
