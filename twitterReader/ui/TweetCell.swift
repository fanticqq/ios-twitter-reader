import UIKit

class TweetCell: UITableViewCell {

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blue
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var tweetTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var avatarImageVIew: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialSetup()
    }

    var tweet: Tweet? {
        didSet {
            if let tweet = tweet {
                self.tweetTextLabel.text = tweet.text
                self.nameLabel.text = "@" + tweet.screenName
                if let urlString = tweet.profileImageUrl,
                    let url = URL(string: urlString) {
                    self.avatarImageVIew.setImage(from: url)
                } else {
                    self.avatarImageVIew.image = nil
                }
            }
        }
    }
    
    override func updateConstraints() {
        self.avatarImageVIew.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        self.avatarImageVIew.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16).isActive = true
        self.avatarImageVIew.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.avatarImageVIew.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.nameLabel.bottomAnchor.constraint(equalTo: self.avatarImageVIew.centerYAnchor).isActive = true
        self.nameLabel.leftAnchor.constraint(equalTo: self.avatarImageVIew.rightAnchor, constant: 8).isActive = true
        self.nameLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -16).isActive = true
        
        self.tweetTextLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 1).isActive = true
        self.tweetTextLabel.leftAnchor.constraint(equalTo: self.avatarImageVIew.rightAnchor, constant: 8).isActive = true
        self.tweetTextLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -16).isActive = true
        
        super.updateConstraints()
    }
    
    private func initialSetup() {
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.tweetTextLabel)
        self.contentView.addSubview(self.avatarImageVIew)
        self.setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
}
