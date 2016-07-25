import Foundation

class TwitterRequestController: NSObject {

    typealias OnTokenResultListener = (response:[String:AnyObject]?, error:NSError?) -> Void
    typealias OnTimelineResultListener = (response:[Tweet]?, error:NSError?) -> Void

    private static let API_ROOT_URL: String = "https://api.twitter.com/"

    //Auth
    private static let API_AUTH_URL: String = API_ROOT_URL + "oauth2/token"

    private static let API_TIMELINE_URL: String = API_ROOT_URL + "1.1/statuses/user_timeline.json?screen_name=fanticqq"

    func obtainBearerToken(requestTokenCallback: (String?) -> Void) {
        let token = PreferencesManager.readBearerToken()
        if token == nil {
            requestBearerToken() {
                response, error in
                if error != nil {
                    print("Finished with error: \(error)")
                    return
                }
                guard let tokenResponse = response else {
                    print("Response equals nil without error")
                    return
                }
                let bearerToken = tokenResponse["access_token"] as? String
                print("token async = \(bearerToken)")
                requestTokenCallback(bearerToken)
                PreferencesManager.saveBearerToken(bearerToken!)
            }
        } else {
            requestTokenCallback(token)
        }
    }

    func pullTimeline(token: String, count: Int, maxId: Int, listener: OnTimelineResultListener) {
        requestTimeline(token, count: count, maxId: maxId, minId: 0, listener: listener)
    }

    func pullTimeline(token: String, minId: Int, listener: OnTimelineResultListener) {
        requestTimeline(token, count: minId != 0 ? 0 : 20, maxId: 0, minId: minId, listener: listener)
    }

    func pullTimeline(token: String, count: Int, listener: OnTimelineResultListener) {
        requestTimeline(token, count: count, maxId: 0, minId: 0, listener: listener)
    }

    private func requestTimeline(token: String, count: Int, maxId: Int, minId: Int, listener: OnTimelineResultListener) {
        print("requestTimeline")
        var url = TwitterRequestController.API_TIMELINE_URL
        if (count > 0) {
            url += "&count=\(count)"
        }
        if (maxId != 0) {
            url += "&max_id=\(maxId)"
        }
        if (minId != 0) {
            url += "&since_id=\(minId)"
        }
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)

        request.HTTPMethod = MethodType.GET.description
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("api.twitter.com", forHTTPHeaderField: "Host")
        request.addValue("Twitter IOS Test Application", forHTTPHeaderField: "User-Agent")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.timeoutInterval = 60
        request.HTTPShouldHandleCookies = false

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            guard error == nil else {
                listener(response: nil, error: error)
                return
            }
            if let httpResponse = response as? NSHTTPURLResponse {
                let statusCode = httpResponse.statusCode
                guard statusCode == 200 else {
                    listener(response: nil, error: NSError(domain: "Request finished with bad code: \(statusCode)", code: statusCode, userInfo: nil))
                    return
                }
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                let result = json as! [[String:AnyObject]]
                print(json)
                var response: [Tweet] = []
                for dict in result {
                    for (k, v) in dict {
                        print("\(k) = \(v)")
                    }
                    response.append(Tweet.initFromJSON(dict))
                }
                listener(response: response, error: nil)
            } catch let error as NSError {
                listener(response: nil, error: error)
            }
        }
        task.resume()
    }

    private func requestBearerToken(callback: OnTokenResultListener) {

        let request = NSMutableURLRequest(URL: NSURL(string: TwitterRequestController.API_AUTH_URL)!)

        request.HTTPMethod = MethodType.POST.description
        request.setValue("api.twitter.com", forHTTPHeaderField: "Host")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(encodeKeys())", forHTTPHeaderField: "Authorization")
        request.setValue("Twitter IOS Test Application", forHTTPHeaderField: "User-Agent")
        request.setValue("29", forHTTPHeaderField: "Content-Length")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")

        request.HTTPBody = ("grant_type=client_credentials" as NSString).dataUsingEncoding(NSUTF8StringEncoding)

        request.timeoutInterval = 60
        request.HTTPShouldHandleCookies = false
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            guard error == nil else {
                callback(response: nil, error: error)
                return
            }
            if let httpResponse = response as? NSHTTPURLResponse {
                let statusCode = httpResponse.statusCode
                guard statusCode == 200 else {
                    callback(response: nil, error: NSError(domain: "Http response non OK. Code: \(statusCode)", code: statusCode, userInfo: nil))
                    return
                }
            }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                callback(response: result, error: nil)
            } catch let error as NSError {
                callback(response: nil, error: error)
            }
        }
        task.resume()
    }

    private func encodeKeys() -> String {
        return Utils.base64("\(BuildVars.ApiKey):\(BuildVars.ApiSecret)")
    }
}