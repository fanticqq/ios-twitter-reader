import UIKit
import CoreData
import RxSwift
import RealmSwift

class TweetsViewController: UITableViewController {
    
    var viewModel: TweetsViewModel = TweetsViewModel()
    
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(TweetCell.self, forCellReuseIdentifier: String(describing: TweetCell.self))
        self.refreshControl = self.createRefreshView()
        self.viewModel.observableChanges
            .do(onError: { print($0) })
            .subscribe(onNext: { [unowned self] (change) in
                self.tableView.applyChanges(changes: change)
            }).disposed(by: self.bag)
        self.viewModel
            .fetchTweets()
            .subscribe(onNext: { [unowned self] in self.tableView.reloadData() }, onError: { print($0)})
            .disposed(by: self.bag)
        self.tableView.rx.isApproachingToBottom
            .debounce(0.1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { approaching in
                guard approaching else { return }
                self.viewModel.loadMore()
            }).disposed(by: self.bag)
    }
    
    @objc func refresh() {
        self.viewModel.refresh()
    }
    
    func createRefreshView() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTweets
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TweetCell.self), for: indexPath) as! TweetCell
        let model = self.viewModel.makeTweetCellViewModel(forTweetAt: indexPath.row)
        model.configure(cell: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
