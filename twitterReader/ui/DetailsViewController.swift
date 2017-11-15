//
//  DetailsViewController.swift
//  twitterReader
//
//  Created by Igor Zarubin on 15/11/2017.
//  Copyright © 2017 Igor. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    var tweet: Tweet!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.text = tweet.text
    }
}
