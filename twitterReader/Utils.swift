import Foundation
import Security

public class Utils {
    
    public static func generateSalt() -> String {
        return generateSalt(32)
    }
    
    public static func generateSalt(length: Int) -> String {
        
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".characters
        let lettersLength = UInt32(letters.count)
        
        let randomCharacters = (0..<length).map { i -> String in
            let offset = Int(arc4random_uniform(lettersLength))
            let c = letters[letters.startIndex.advancedBy(offset)]
            return String(c)
        }
        
        return randomCharacters.joinWithSeparator("")
    }
    
    public static func percentEncode(string : String) -> String {
        return string.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
    }
    
    public static func generateSignature(methodType: String, request: String, params: [RequestParam]) -> String {
        var paramsString = ""
        for i in 0 ..< params.count {
            let param = params[i] as RequestParam
            paramsString += param.key + "=" + param.value
            if(i < params.count - 1) {
                paramsString += "&"
            }
        }
        
        return methodType + "&" + percentEncode(request) + "&" + percentEncode(paramsString)
    }
    
    public static func generateSigningKey(consumerKey: String, tokenSecret: String) -> String {
        return percentEncode(consumerKey) + "&" + percentEncode(tokenSecret)
    }
    
    public static func base64(input: String) -> String {
        let utf8str = input.dataUsingEncoding(NSUTF8StringEncoding)
        
        return utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
}