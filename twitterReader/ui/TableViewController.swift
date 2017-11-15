import UIKit
import CoreData
import RxSwift

class TableViewController: UITableViewController {
    
    var requestController: TwitterController!
    var tweets: [Tweet] = []
    
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feed"
        
        requestController = TwitterController()
        tweets = DataManager.loadTweets()
        tweets.sort(by: {$0.id > $1.id})
        requestController.obtainBearerToken()
            .subscribeOn(MainScheduler())
            .subscribe(onNext: { [unowned self] token in
                self.requestController.pullTimeline(token: token, count: 20)
                    .observeOn(MainScheduler())
                    .subscribe(onNext: { tweets in
                        if self.tweets.isEmpty {
                            self.tweets = tweets
                            self.tableView.reloadData()
                        }
                    }).disposed(by: self.bag)
            }).disposed(by: self.bag)
        self.tableView.register(TweetCell.self, forCellReuseIdentifier: String(describing: TweetCell.self))
        self.refreshControl = self.createRefreshView()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maxOffsetY = scrollView.contentSize.height - scrollView.frame.size.height
        if maxOffsetY - currentOffsetY <= 200 {
            loadMore()
        }
    }
    
    @objc func refresh() {
        if let token = PreferencesManager.readBearerToken() {
            self.requestController.pullTimeline(token: token, count: 20)
                .observeOn(MainScheduler())
                .subscribe(onNext: { [unowned self] (tweets) in
                    self.tweets = tweets
                    self.tableView.reloadData()
                }).disposed(by: self.bag)
        }
    }
    
    func loadMore() {
        guard !self.tweets.isEmpty else {
            return
        }
        if let token = PreferencesManager.readBearerToken() {
            self.requestController.pullTimeline(token: token, count: 20, maxId: tweets[tweets.count - 1].id - 1)
                .observeOn(MainScheduler())
                .subscribe(onNext: { [unowned self] (tweets) in
                    self.refreshControl?.endRefreshing()
                    let indices = tweets.enumerated().map { IndexPath(row: $0.offset + self.tweets.endIndex, section: 0) }
                    self.tweets.append(contentsOf: tweets)
                    self.tableView.insertRows(at: indices, with: .automatic)
                }).disposed(by: self.bag)
        }
    }
    
    func createRefreshView() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TweetCell.self), for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
