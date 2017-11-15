//
//  UIImageView.swift
//  twitterReader
//
//  Created by Igor Zarubin on 15/11/2017.
//  Copyright © 2017 Igor. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setImage(from url: URL) {
        self.kf.setImage(with: url)
    }
}

extension String {
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
