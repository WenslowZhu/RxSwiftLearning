//
//  PHPhotoLibrary+rx.swift
//  RxSwiftLearning
//
//  Created by Wenslow on 2018/3/5.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Photos

extension PHPhotoLibrary {
    static var authorized: Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    requestAuthorization({ (newStatus) in
                        observer.onNext(newStatus == .authorized)
                        observer.onCompleted()
                    })
                }
            }
            return Disposables.create()
        })
    }
}
