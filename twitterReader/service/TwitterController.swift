import Foundation

import RxSwift
import RealmSwift

class TwitterController {

    private static let API_ROOT_URL: String = "https://api.twitter.com/"

    private static let API_AUTH_URL: String = API_ROOT_URL + "oauth2/token"

    private static let API_TIMELINE_URL: String = API_ROOT_URL + "1.1/statuses/user_timeline.json?screen_name=twitterapi"
    
    private static let FIELD_TOKEN = "twitter_token"
    
    private var token: String?
    private var loading = false

    func obtainTokenIfNeeded() -> Observable<String> {
        if let token = self.token {
            return Observable.just(token)
        } else if let token = UserDefaults.standard.string(forKey: TwitterController.FIELD_TOKEN) {
            return Observable.just(token)
        } else {
            return self.requestBearerToken()
        }
    }
    
    func dropCache() {
        RealmController.realmWrite {
            RealmController.mainRealm.deleteAll()
        }
    }
    
    func fetchTweets(from identifier: Int? = nil, since: Int? = nil) -> Observable<[Tweet]> {
        return obtainTokenIfNeeded().flatMap { (token) -> Observable<[Tweet]> in
            return self.requestTimeline(token: token, maxId: identifier, minId: since)
        }
    }
    
    func obtainTweetsFromCache() -> Observable<[Tweet]> {
        if RealmController.mainRealm.isEmpty {
            return fetchTweets()
        } else {
            let tweets: [Tweet] = RealmController.mainRealm.objects(Tweet.self).map { $0 }
            return Observable.just(tweets)
        }
    }

    private func requestTimeline(token: String, maxId: Int?, minId: Int?) -> Observable<[Tweet]> {
        guard !self.loading else {
            return Observable.create { observer in
                observer.onCompleted()
                return Disposables.create()
            }
        }
        self.loading = true
        var url = TwitterController.API_TIMELINE_URL + "&count=\(50)"
        if let maxId = maxId {
            url += "&max_id=\(maxId)"
        }
        if let minId = minId {
            url += "&since_id=\(minId)"
        }
        var request = URLRequest(url: URL(string: url)!)

        request.httpMethod = MethodType.GET.description
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("api.twitter.com", forHTTPHeaderField: "Host")
        request.addValue("Twitter IOS Test Application", forHTTPHeaderField: "User-Agent")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.timeoutInterval = 60
        request.httpShouldHandleCookies = false

        return Observable.create { [unowned self] (observer) in
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                self.loading = false
                if let error = error {
                    observer.onError(error)
                } else {
                    do {
                        let result = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String:AnyObject]]
                        let realm = try Realm()
                        let tweets: [Tweet] = result.flatMap { Tweet.create(with:$0,into:realm) }
                        RealmController.realmWrite(realm: realm) {
                            realm.add(tweets)
                        }
                        observer.onNext(tweets)
                    } catch {
                        observer.onError(error)
                    }
                }
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create(with: {
                task.cancel()
            })
        }
    }

    private func requestBearerToken() -> Observable<String> {

        var request = URLRequest(url: URL(string: TwitterController.API_AUTH_URL)!)

        request.httpMethod = MethodType.POST.description
        request.setValue("api.twitter.com", forHTTPHeaderField: "Host")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(BuildVars.encodeKeys())", forHTTPHeaderField: "Authorization")
        request.setValue("Twitter IOS Test Application", forHTTPHeaderField: "User-Agent")
        request.setValue("29", forHTTPHeaderField: "Content-Length")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")

        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        request.timeoutInterval = 60
        request.httpShouldHandleCookies = false
        return Observable.create { observable in
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                if let error = error {
                    observable.onError(error)
                } else {
                    do {
                        let result = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
                        let bearerToken = result["access_token"] as! String
                        observable.onNext(bearerToken)
                        self.token = bearerToken
                        UserDefaults.standard.set(bearerToken, forKey: TwitterController.FIELD_TOKEN)
                    } catch {
                        observable.onError(error)
                    }
                }
                observable.onCompleted()
            }
            task.resume()
            return Disposables.create(with: {
                task.cancel()
            })
        }
    }
}
