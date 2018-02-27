//
//  RootViewController.swift
//  RxSwiftLearning
//
//  Created by apple on 2018/2/27.
//  Copyright © 2018年 FordTZ.com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RootViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
}
