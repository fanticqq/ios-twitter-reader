import Foundation

import RxSwift

class TwitterController {

    private static let API_ROOT_URL: String = "https://api.twitter.com/"

    private static let API_AUTH_URL: String = API_ROOT_URL + "oauth2/token"

    private static let API_TIMELINE_URL: String = API_ROOT_URL + "1.1/statuses/user_timeline.json?screen_name=twitterapi"
    
    private static let FIELD_TOKEN = "twitter_token"
    
    private var token: String?
    private var loading = false

    func obtainBearerToken() -> Observable<String> {
        if let token = self.token {
            return Observable.just(token)
        } else if let token = UserDefaults.standard.string(forKey: TwitterController.FIELD_TOKEN) {
            return Observable.just(token)
        } else {
            return self.requestBearerToken()
        }
    }

    func pullTimeline(token: String, maxId: Int) -> Observable<[Tweet]> {
        return requestTimeline(token: token, maxId: maxId, minId: 0)
    }

    func pullTimeline(token: String) -> Observable<[Tweet]> {
        return requestTimeline(token: token, maxId: 0, minId: 0)
    }

    private func requestTimeline(token: String, maxId: Int, minId: Int) -> Observable<[Tweet]> {
        guard !self.loading else {
            return Observable.create { observer in
                observer.onCompleted()
                return Disposables.create()
            }
        }
        self.loading = true
        var url = TwitterController.API_TIMELINE_URL
        url += "&count=\(50)"
        if (maxId != 0) {
            url += "&max_id=\(maxId)"
        }
        if (minId != 0) {
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
                        let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String:AnyObject]]
                        let tweets: [Tweet] = result?.flatMap(Tweet.create) ?? []
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
