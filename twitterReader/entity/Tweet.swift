import Foundation
import UIKit

final class Tweet {

    class Entity {
        static let ENTITY_NAME = "Tweet"
        static let ID = "tweet_id"
        static let TEXT = "text"
        static let SCREEN_NAME = "screen_name"
        static let PROFILE_IMAGE_URL = "profile_image_url"
    }

    var id: Int = 0
    var text: String
    var screenName: String
    var profileImageUrl: URL?
    
    init(id: Int, text: String, screenName: String, profileImageUrl: URL?) {
        self.id = id
        self.text = text
        self.screenName = screenName
        self.profileImageUrl = profileImageUrl
    }
    
    init?(json: [String:AnyObject]) {
        guard let id = json["id"] as? Int,
            let text = json["text"] as? String,
            let userJSON = json["user"] as? [String:AnyObject],
            let userName = userJSON["screen_name"] as? String,
            let url = userJSON["profile_image_url_https"] as? String else {
                return nil
        }
        self.id = id
        self.text = text
        self.screenName = userName
        self.profileImageUrl = URL(string: url)
    }
}
