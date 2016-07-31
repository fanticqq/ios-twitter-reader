import UIKit
import CoreData

final class DataManager {

    class func saveTweets(tweetBatch: [Tweet]) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        context.performBlock {
            autoreleasepool {
                for tweet in tweetBatch {
                    let entity = NSEntityDescription.insertNewObjectForEntityForName(Tweet.Entity
                    .ENTITY_NAME, inManagedObjectContext: context)
                    entity.setValue(tweet.id, forKey: Tweet.Entity.ID)
                    entity.setValue(tweet.text, forKey: Tweet.Entity.TEXT)
                    entity.setValue(tweet.screenName, forKey: Tweet.Entity.SCREEN_NAME)
                    entity.setValue(tweet.profileImageUrl, forKey: Tweet.Entity.PROFILE_IMAGE_URL)
                    do {
                        try context.save()
                    } catch {
                        print("error while saving entity: \(error)")
                    }
                }
            }
        }
    }

    class func loadTweets() -> [Tweet] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: Tweet.Entity.ENTITY_NAME)
        var result: [Tweet] = []
        do {
            let fetchedResult = try context.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for entity in fetchedResult {
                let tweet = Tweet()
                tweet.id = entity.valueForKey(Tweet.Entity.ID) as! Int
                tweet.text = entity.valueForKey(Tweet.Entity.TEXT) as! String
                tweet.screenName = entity.valueForKey(Tweet.Entity.SCREEN_NAME) as! String
                tweet.profileImageUrl = entity.valueForKey(Tweet.Entity.PROFILE_IMAGE_URL) as! String
                result.append(tweet)
            }
        } catch {
            print("error while fetching data: \(error)")
        }
        return result
    }
}
