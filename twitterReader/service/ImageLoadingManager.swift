import Foundation
import UIKit
import CoreData

final class ImageLoadingManager {

    static let sharedInstance = ImageLoadingManager()

    private var imageCache = [String: UIImage]()
    class Entity {
        static let ENTITY_NAME = "Image"
        static let IMAGE_URL = "profile_image_url"
        static let IMAGE = "profile_image"
    }

    private init() {
    }

    func loadImage(urlString: String, imageLoadedCallback: (image:UIImage) -> Void) {
        if let image = imageCache[urlString] {
            imageLoadedCallback(image: image)
        } else {
            NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: {
                (data, response, error) -> Void in

                if error != nil {
                    print(error)
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    let image = UIImage(data: data!)
                    self.saveImage(urlString, image: image!)
                    imageLoadedCallback(image: image!)
                })

            }).resume()
        }
    }

    private func saveImage(url: String, image: UIImage) {
        imageCache[url] = image
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        context.performBlock {
            let entity = NSEntityDescription.insertNewObjectForEntityForName(Entity.ENTITY_NAME, inManagedObjectContext: context)
            entity.setValue(url, forKey: Entity.IMAGE_URL)
            entity.setValue(UIImagePNGRepresentation(image), forKey: Entity.IMAGE)
            do {
                try context.save()
            } catch {
                print("error while saving entity: \(error)")
            }
        }
    }

    func initialize() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: Entity.ENTITY_NAME)
        do {
            let fetchedResult = try context.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for entity in fetchedResult {
                let imageKey = entity.valueForKey(Entity.IMAGE_URL) as! String
                let imageValue = entity.valueForKey(Entity.IMAGE) as! NSData
                imageCache[imageKey] = UIImage(data: imageValue)
            }
        } catch {
            print("error while fetching data: \(error)")
        }
    }
}
