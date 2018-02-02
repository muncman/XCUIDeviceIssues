//
//  DetailViewController.swift
//  XCUIDeviceIssues
//
//  Created by Kevin Munc on 12/13/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    var detailItem: NSDate? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

}

