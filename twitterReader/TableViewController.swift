import UIKit

class TableViewController: UITableViewController {

    var requestController: TwitterRequestController?
    var tweets: [Tweet] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Random tweets"

        requestController = TwitterRequestController()
        requestController?.obtainBearerToken() {
            token in
            print("request timeline for token= \(token)")
            self.requestController?.requestTimeline(token!) {
                response, error in
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
        // Do any additional setup after loading the view, typically from a nib.
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