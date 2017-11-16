//
//  UIImageView.swift
//  twitterReader
//
//  Created by Igor Zarubin on 15/11/2017.
//  Copyright © 2017 Igor. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift
import RxSwift
import RxCocoa

extension UITableView {
    
    func applyChanges<T>(changes: RealmCollectionChange<T>) {
        switch changes {
        case .initial: reloadData()
        case .update(_ , let deletions, let insertions, let updates):
            let fromRow = { (row: Int) in return IndexPath(row: row, section: 0) }
            beginUpdates()
            insertRows(at: insertions.map(fromRow), with: .none)
            reloadRows(at: updates.map(fromRow), with: .none)
            deleteRows(at: deletions.map(fromRow), with: .none)
            endUpdates()
        case .error(let error): fatalError("\(error)")
        }
    }
}

extension Reactive where Base: UIScrollView {
    
    public var isApproachingToBottom: Observable<Bool> {
        unowned let base = self.base
        return self.contentOffset.asObservable().map { (offset) -> Bool in
            let maxOffsetY = base.contentSize.height - base.frame.size.height
            return maxOffsetY - offset.y <= 200
        }
    }
}

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
