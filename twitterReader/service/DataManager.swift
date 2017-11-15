import UIKit
import CoreData

final class DataManager {

    class func saveTweets(tweetBatch: [Tweet]) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.managedObjectContext
//        context.perform {
//            autoreleasepool {
//                for tweet in tweetBatch {
//                    let entity = NSEntityDescription.insertNewObject(forEntityName: Tweet.Entity
//                        .ENTITY_NAME, into: context)
//                    entity.setValue(tweet.id, forKey: Tweet.Entity.ID)
//                    entity.setValue(tweet.text, forKey: Tweet.Entity.TEXT)
//                    entity.setValue(tweet.screenName, forKey: Tweet.Entity.SCREEN_NAME)
//                    entity.setValue(tweet.profileImageUrl, forKey: Tweet.Entity.PROFILE_IMAGE_URL)
//                    do {
//                        try context.save()
//                    } catch {
//                        print("error while saving entity: \(error)")
//                    }
//                }
//            }
//        }
    }

    class func loadTweets() -> [Tweet] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Tweet.Entity.ENTITY_NAME)
        var result: [Tweet] = []
//        do {
//            let fetchedResult = try context.fetch(fetchRequest) as! [NSManagedObject]
//            for entity in fetchedResult {
//                let tweet = Tweet(id: entity.valueForKey(Tweet.Entity.ID) as! Int,
//                                  text: entity.valueForKey(Tweet.Entity.TEXT) as! String,
//                                  screenName: entity.valueForKey(Tweet.Entity.SCREEN_NAME) as! String, profileImageUrl: entity.valueForKey(Tweet.Entity.PROFILE_IMAGE_URL) as! URL)
//                result.append(tweet)
//            }
//        } catch {
//            print("error while fetching data: \(error)")
//        }
        return result
    }
}
