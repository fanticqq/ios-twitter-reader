import Foundation
import UIKit

class Tweet {

    class Entity {
        static let ENTITY_NAME = "Tweet"
        static let ID = "tweet_id"
        static let TEXT = "text"
        static let SCREEN_NAME = "screen_name"
        static let PROFILE_IMAGE_URL = "profile_image_url"
    }

    var id: Int = 0
    var text: String?
    var screenName: String?
    var profileImageUrl: String?


    class func createFromJSON(json: [String:AnyObject]) -> Tweet {
        let tweet: Tweet = Tweet()
        tweet.id = json["id"] as! Int
        tweet.text = json["text"] as? String
        tweet.screenName = json["user"]!["screen_name"] as? String
        tweet.profileImageUrl = json["user"]!["profile_image_url_https"] as? String
        return tweet
    }
}