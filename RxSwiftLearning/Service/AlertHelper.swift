//
//  AlertHelper.swift
//  RxSwiftLearning
//
//  Created by Wenslow on 2018/2/28.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit

class AlertHelper: NSObject {
    class func commonAlert(title: String, massage: String? = nil)->UIAlertController{
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return ac
    }
}
