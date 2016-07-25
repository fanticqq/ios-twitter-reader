import UIKit

class TableViewController: UITableViewController {

    var requestController: TwitterRequestController?
    var tweets: [Tweet] = []
    var loading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Random tweets"

        requestController = TwitterRequestController()
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
                for tweet in response! {
                    print("user_id = \(tweet.id) user_name = \(tweet.profileName) text = \(tweet.text)")
                }
                self.tweets = response!
                self.tableView.reloadData()
            }
        }
        tableView.registerClass(TweetCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.separatorColor = UIColor.grayColor()
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Loading...")
        refreshControl!.addTarget(self, action: #selector(refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        tableView.tableFooterView?.hidden = true
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maxOffsetY = scrollView.contentSize.height - scrollView.frame.size.height
        if maxOffsetY - currentOffsetY <= 0 {
            loadMore()
        }
    }

    func refresh() {
        if(!loading) {
            loading = true
            let token = PreferencesManager.readBearerToken()
            var minId = 0
            if(self.tweets.count > 0) {
                minId = tweets[0].id + 1
            }
            self.requestController?.pullTimeline(token!, minId: minId) {
                response, error in
                print("reloaded")
                self.loading = false
                guard error == nil else {
                    print("error getting user timeline: \(error)")
                    return
                }
                for tweet in response! {
                    print("reloading user_id = \(tweet.id) user_name = \(tweet.profileName) text = \(tweet.text)")
                }
                self.tweets = response! + self.tweets
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    func loadMore() {
        if(!loading) {
            loading = true
            let token = PreferencesManager.readBearerToken()
            self.requestController?.pullTimeline(token!, count: 20, maxId: tweets[tweets.count - 1].id - 1) {
                response, error in
                self.loading = false
                guard error == nil else {
                    print("error getting user timeline: \(error)")
                    return
                }
                for tweet in response! {
                    print("user_id = \(tweet.id) user_name = \(tweet.profileName) text = \(tweet.text)")
                }
                self.tweets += response!
                self.tableView.reloadData()
            }
        }
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