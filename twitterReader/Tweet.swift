import Foundation

class Tweet {
    var id: Int = 0
    var text: String?
    var profileName: String?
    var profileImageUrl: String?

    static func initFromJSON(json: [String:AnyObject]) -> Tweet {
        let tweet: Tweet = Tweet()
        tweet.id = json["id"] as! Int
        tweet.text = json["text"] as? String
        tweet.profileName = json["name"] as? String
        tweet.profileImageUrl = json["profile_image_url_https"] as? String
        return tweet
    }
}