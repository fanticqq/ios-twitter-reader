import Foundation

class BuildVars {
    static let ApiKey : String = "LrgstghsiNte3ZPNJhM2gGIvY"
    static let ApiSecret : String = "Z8j4xiqxjwp4368psyaWHUoxqZjzeb6sVyBiKN1Ix3CS06nYYt"
    
    class func encodeKeys() -> String {
        return "\(ApiKey):\(ApiSecret)".toBase64()
    }
}
