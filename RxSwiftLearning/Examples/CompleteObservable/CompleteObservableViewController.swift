//
//  CompleteObservableViewController.swift
//  RxSwiftLearning
//
//  Created by Wenslow on 2018/2/28.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate let imageURLString = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/PM5544_with_non-PAL_signals.png/384px-PM5544_with_non-PAL_signals.png"

class CompleteObservableViewController: RxViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageOutlet: UIImageView!
    
    // 使用NSCache
    private var cache = NSCache<AnyObject, AnyObject>()
    private var cachedImage: UIImage?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cacheImage()
            .subscribe(onCompleted: {[weak self] in
                self?.imageOutlet.image = self?.cachedImage
            }) { (error) in
                print(error)
        }.disposed(by: disposeBag)
    }
    
    private func cacheImage() -> Completable{        
        return Completable.create(subscribe: { (completable) in
            
            let downloadTask = URLSession.shared.dataTask(with: URL(string: imageURLString)!, completionHandler: { [weak self] (data, response, error) in
                
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
                
                if let error = error {
                    completable(.error(error))
                    return
                }
                // 获得图片并且保存 主线程返回
                if let data = data {
                    self?.cachedImage = UIImage(data: data)
                    self?.cache.setObject(data as AnyObject, forKey: imageURLString as AnyObject)
                    completable(.completed)
                    return
                }
                
                self?.present(AlertHelper.commonAlert(title: "No Image Cached"), animated: true, completion: nil)
            })
            downloadTask.resume()
            return Disposables.create {
                downloadTask.cancel()
            }
        }).observeOn(MainScheduler.asyncInstance)
    }
}
