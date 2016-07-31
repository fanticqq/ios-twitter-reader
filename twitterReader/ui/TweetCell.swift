import UIKit

public class TweetCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var avatarImageVIew: UIImageView!

    var tweet: Tweet? {
        didSet {
            if let tweet = tweet {
                self.tweetTextLabel.text = tweet.text
                self.nameLabel.text = "@" + tweet.screenName!
                self.avatarImageVIew.imageFromServerURL(tweet.profileImageUrl);
                setNeedsLayout()
            }
        }
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: String?) {
        guard urlString != nil else {
            return;
        }

        ImageLoadingManager.sharedInstance.loadImage(urlString!) {
            loadedImage in
            self.image = loadedImage;
        }
    }
}