//
//  TweetsViewModel.swift
//  twitterReader
//
//  Created by Igor Zarubin on 16/11/2017.
//  Copyright © 2017 Igor. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

final class TweetsViewModel {
    
    private var requestController: TwitterController = TwitterController()
    
    private var token: NotificationToken?
    private var bag: DisposeBag = DisposeBag()
    
    lazy var tweets: Variable<Results<Tweet>> = Variable(RealmController.mainRealm.objects(Tweet.self))
    
    lazy var observableChanges: Observable<RealmCollectionChange<Results<Tweet>>> = {
        return Observable.create { [unowned self] observer in
            self.token = self.tweets.value.observe { (changes) in
                observer.onNext(changes)
            }
            return Disposables.create()
        }
    }()
    
    func makeTweetCellViewModel(forTweetAt index: Int) -> TweetCellViewModel {
        let tweet = tweets.value[index]
        return TweetCellViewModel(tweet: tweet)
    }
    
    var numberOfTweets: Int {
        return tweets.value.count
    }
    
    func fetchTweets() -> Observable<Void> {
        return self.requestController
            .fetchTweets()
            .observeOn(MainScheduler())
            .map { _ in
                RealmController.mainRealm.refresh()
                return
        }
    }
    
    func refresh() {
        guard let sinceId = self.tweets.value.first?.id else { return }
        self.requestController
            .fetchTweets(since: sinceId)
            .observeOn(MainScheduler())
            .do(onError: { print($0) })
            .subscribe(onNext: { _ in
                RealmController.mainRealm.refresh()
            })
            .disposed(by: self.bag)
    }
    
    func loadMore() {
        guard self.numberOfTweets > 0,
            let maxId = self.tweets.value.last?.id else {
                return
        }
        self.requestController
            .fetchTweets(from: maxId)
            .observeOn(MainScheduler())
            .do(onError: { print($0) })
            .subscribe(onNext: {_ in
                RealmController.mainRealm.refresh()
            })
            .disposed(by: self.bag)
    }
    
    deinit {
        token?.invalidate()
    }
}
