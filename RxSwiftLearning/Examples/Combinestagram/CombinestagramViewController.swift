//
//  CombinestagramViewController.swift
//  RxSwiftLearning
//
//  Created by Wenslow on 2018/3/5.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class CombinestagramViewController: RxViewController {

    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    @IBOutlet weak var imageIcon: UIImageView!
    
    private let images = Variable<[UIImage]>([])
    private var photosViewController: PhotosViewController!
    private var imageCache = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        actions()
        observables()
    }
    
    private func actions() {
        itemAdd.rx.tap.subscribe {[weak self] _ in
//            guard let image = UIImage(named: "IMG_1907.jpg") else {return}
//            self?.images.value.append(image)
//            guard let photosViewController = self?.storyboard?.instantiateViewController(withIdentifier: "PhotosViewController") as? PhotosViewController else {return}
            guard let photosViewController = UIStoryboard(name: "PhotosViewController", bundle: nil).instantiateViewController(withIdentifier: "PhotosViewController") as? PhotosViewController else {return}
            self?.photosViewController = photosViewController
            self?.navigationController?.pushViewController(photosViewController, animated: true)
            self?.observePhotoViewController()
            }.disposed(by: disposeBag)
        
        // clear 按钮的事件
        buttonClear.rx.tap.subscribe{[weak self] _ in
            self?.images.value = []
            self?.imageCache = []
            self?.imageIcon.image = nil
        }.disposed(by: disposeBag)
        
        //保存按钮的事件
        buttonSave.rx.tap.subscribe{[weak self] _ in
            guard let image = self?.imagePreview.image else {return}
            self?.savePhoto(image: image)
        }.disposed(by: disposeBag)
    }
    
    private func observables() {
        images.asObservable()
            // 避免用户的频繁输入
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (photos) in
                self?.updateUIs(photos: photos)
                guard let preview = self?.imagePreview else {return}
                preview.image = UIImage.collage(images: photos, size: preview.frame.size)
        }).disposed(by: disposeBag)
        
//        //没有图片时, clear按钮不可用
//        images.asObservable()
//            .map{!$0.isEmpty}
//            .bind(to: buttonClear.rx.isEnabled).disposed(by: disposeBag)
//
//        //没有图片或图片数量为奇数时, save按钮不可用
//        images.asObservable()
//            .map{$0.count}
//            .subscribe(onNext: { [weak self] (count) in
//                if count == 0 || count % 2 != 0 {
//                    self?.buttonSave.isEnabled = false
//                } else {
//                    self?.buttonSave.isEnabled = true
//                }
//            }).disposed(by: disposeBag)
//
//        //导航栏显示图片数量
//        images.asDriver()
//            .map{"\($0.count) photos"}
//            .drive(navigationItem.rx.title).disposed(by: disposeBag)
    }
    
    private func updateUIs(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = !photos.isEmpty
        itemAdd.isEnabled = photos.count < 6
        navigationItem.title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
    
    private func observePhotoViewController() {
        guard let photosViewController = self.photosViewController else { return }
//        photosViewController.selectedPhotos.subscribe(onNext: { [weak self](newImage) in
//            guard let images = self?.images, images.value.count < 6 else {return}
//            images.value.append(newImage)
//            }, onDisposed: {
//                print("completed photo selection")
//        }).disposed(by: disposeBag)
        let newPhotos = photosViewController.selectedPhotos.share()
        newPhotos
            //图片数量不能大于6张
            .takeWhile({ [weak self] (_) -> Bool in
                return (self?.images.value.count ?? 0) < 6
            })
            //过滤高比宽大的图片
            .filter({ (image) -> Bool in
                return image.size.width > image.size.height
            })
            //过滤重复的图片
            .filter({ [weak self] (newImage) -> Bool in
                let len = UIImagePNGRepresentation(newImage)?.count ?? 0
                guard self?.imageCache.contains(len) == false else {return false}
                self?.imageCache.append(len)
                return true
            })
            .subscribe(onNext: { [weak self] (newImage) in
                self?.images.value.append(newImage)
                }, onCompleted: {[weak self] in
                     self?.updateNavigationIcon()
                }, onDisposed: {
                    print("completed photo selection")
            }).disposed(by: photosViewController.bag)
    }
    
    private func savePhoto(image: UIImage){
        PhotoWriter.save(image)
            .subscribe(onSuccess: { [weak self] (id) in
                self?.showMessage("Saved with " + id)
                self?.buttonClear.sendActions(for: .touchUpInside)
                }, onError: { [weak self] (error) in
                    self?.showMessage("Error", description: error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    private func showMessage(_ title: String, description: String? = nil){
        alert(title, description: description).subscribe().disposed(by: disposeBag)
    }
    
    private func updateNavigationIcon() {
        imageIcon.image = imagePreview.image?.scaled(CGSize(width: 22, height: 22)).withRenderingMode(.alwaysOriginal)
    }
}
