import Foundation
import UIKit
import RealmSwift

class Tweet: Object {

    @objc var id: Int = 0
    @objc var text: String = ""
    @objc var screenName: String = ""
    @objc var profileImageUrl: String?
    
    class func create(with json: [String:AnyObject]) -> Tweet? {
        guard let id = json["id"] as? Int,
            let text = json["text"] as? String,
            let userJSON = json["user"] as? [String:AnyObject],
            let userName = userJSON["screen_name"] as? String,
            let url = userJSON["profile_image_url_https"] as? String else {
                return nil
        }
        let tweet = Tweet()
        tweet.id = id
        tweet.text = text
        tweet.screenName = userName
        tweet.profileImageUrl = url
        return tweet
    }
}
