import UIKit
import CoreData

class TableViewController: UITableViewController {

    var requestController: TwitterRequestManager?
    var tweets: [Tweet] = []
    var loading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feed"

        requestController = TwitterRequestManager()
        tweets = DataManager.loadTweets()
        tweets.sortInPlace({$0.id > $1.id})
        requestController?.obtainBearerToken() {
            token in
            print("request timeline for token= \(token)")
            self.loading = true
            self.requestController?.pullTimeline(token!, count: 20) {
                response, error in
                self.loading = false
                guard error == nil else {
                    print("error getting user timeline: \(error)")
                    return
                }
                if self.tweets.isEmpty {
                    self.tweets = response!
                    self.tableView.reloadData()
                    DataManager.saveTweets(self.tweets)
                }
                for tweet in self.tweets {
                    print("tweet id = \(tweet.id) text = \(tweet.text)")
                }
            }
        }
        initializeCell()

        refreshControl = createRefreshView()
        tableView.addSubview(refreshControl!)

        tableView.tableHeaderView = createTableHeader()

        tableView.tableFooterView?.hidden = true
        showHeaderIfNeeded()
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maxOffsetY = scrollView.contentSize.height - scrollView.frame.size.height
        if maxOffsetY - currentOffsetY <= 0 {
            loadMore()
        }
    }

    func showHeaderIfNeeded() -> Bool {
        if let header = tableView.tableHeaderView {
            guard Utils.isConnected() else {
                header.hidden = false
                return true
            }
            if !header.hidden {
                header.hidden = true
            }
        }
        return false
    }

    func refresh() {
        if (showHeaderIfNeeded()) {
            return
        }
        if (!loading) {
            self.loading = true
            let token = PreferencesManager.readBearerToken();
            if tweets.isEmpty {
                self.requestController?.pullTimeline(token!, count: 20) {
                    response, error in
                    self.displayNewTweets(error, response: response)
                }
            } else {
                self.requestController?.pullTimeline(token!, minId: tweets[0].id) {
                    response, error in
                    self.displayNewTweets(error, response: response)
                }
            }
        }
    }

    func displayNewTweets(error: NSError?, response: [Tweet]?) {
        dispatch_async(dispatch_get_main_queue(), {
            () -> Void in
            self.loading = false
            self.refreshControl?.endRefreshing()
            guard error == nil else {
                print("error getting user timeline: \(error)")
                return
            }
            if let tweets = response {
                if !tweets.isEmpty {
                    self.tweets = tweets + self.tweets
                    self.tableView.reloadData()
                    DataManager.saveTweets(tweets)
                }
            }
        })
    }

    func loadMore() {
        if (showHeaderIfNeeded()) {
            return
        }
        if (!loading) {
            loading = true
            let token = PreferencesManager.readBearerToken()
            if token != nil {
                self.requestController?.pullTimeline(token!, count: 20, maxId: tweets[tweets.count - 1].id - 1) {
                    response, error in
                    dispatch_async(dispatch_get_main_queue(), {
                        () -> Void in
                        self.loading = false
                        self.refreshControl?.endRefreshing()
                        guard error == nil else {
                            print("error getting user timeline: \(error)")
                            return
                        }
                        if let tweets = response {
                            self.tweets += tweets
                            self.tableView.reloadData()
                            DataManager.saveTweets(tweets)
                        }
                    })
                }
            }
        }
    }

    func createTableHeader() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view.backgroundColor = UIColor.redColor()
        view.layer.opacity = 0.8

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        label.text = "No internet connection"
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center

        view.addSubview(label)

        return view
    }

    func createRefreshView() -> UIRefreshControl {
        let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }

    func initializeCell() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let cellNib = UINib(nibName: "TweetCell", bundle: bundle)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.separatorColor = UIColor.grayColor()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}