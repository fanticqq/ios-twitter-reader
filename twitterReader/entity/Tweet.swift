import Foundation
import UIKit
import RealmSwift

class Tweet: Object {
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: Int = 0
    @objc dynamic var text: String = ""
    @objc dynamic var screenName: String = ""
    @objc dynamic var profileImageUrl: String?
    
    class func create(with json: [String:AnyObject], into realm: Realm) -> Tweet? {
        guard let id = json["id"] as? Int,
            let text = json["text"] as? String,
            let userJSON = json["user"] as? [String:AnyObject],
            let userName = userJSON["screen_name"] as? String,
            let url = userJSON["profile_image_url_https"] as? String else {
                return nil
        }
        if let tweet = realm.objects(Tweet.self).first(where: { $0.id == id }) {
            return tweet
        } else {
            let tweet = Tweet()
            tweet.id = id
            tweet.text = text
            tweet.screenName = userName
            tweet.profileImageUrl = url
            return tweet
        }
    }
}
