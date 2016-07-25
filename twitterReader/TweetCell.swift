import UIKit

public class TweetCell: UITableViewCell {

    let padding: CGFloat = 5
    var background: UIView!
    var typeLabel: UILabel!
    var nameLabel: UILabel!
    var priceLabel: UILabel!

    var tweet: Tweet? {
        didSet {
            if let tweet = tweet {
                nameLabel.text = tweet.text == nil ? "TEXT" : tweet.text
                typeLabel.text = tweet.profileName
                setNeedsLayout()
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clearColor()
        selectionStyle = .None

        background = UIView(frame: CGRectZero)
        background.alpha = 0.6
        contentView.addSubview(background)

        nameLabel = UILabel(frame: CGRectZero)
        nameLabel.textAlignment = .Left
        nameLabel.textColor = UIColor.blackColor()
        contentView.addSubview(nameLabel)

        typeLabel = UILabel(frame: CGRectZero)
        typeLabel.textAlignment = .Center
        typeLabel.textColor = UIColor.whiteColor()
        contentView.addSubview(typeLabel)

        priceLabel = UILabel(frame: CGRectZero)
        priceLabel.textAlignment = .Center
        priceLabel.textColor = UIColor.whiteColor()
        contentView.addSubview(priceLabel)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        background.frame = CGRectMake(0, padding, frame.width, frame.height - 2 * padding)
        typeLabel.frame = CGRectMake(padding, (frame.height - 25) / 2, 40, 25)
        priceLabel.frame = CGRectMake(frame.width - 100, padding, 100, frame.height - 2 * padding)
        nameLabel.frame = CGRectMake(CGRectGetMaxX(typeLabel.frame) + 10, 0, frame.width - priceLabel.frame.width - (CGRectGetMaxX(typeLabel.frame) + 10), frame.height)
    }
}
