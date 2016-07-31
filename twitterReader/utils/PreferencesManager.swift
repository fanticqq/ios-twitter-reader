import Foundation

final class PreferencesManager {

    private static let FIELD_TOKEN = "TOKEN"

    internal static func readBearerToken() -> String? {
        let preferences = NSUserDefaults.standardUserDefaults()
        return preferences.stringForKey(FIELD_TOKEN)
    }

    internal static func saveBearerToken(token: String) {
        let preferences = NSUserDefaults.standardUserDefaults()
        preferences.setValue(token, forKey: FIELD_TOKEN)
        preferences.synchronize()
    }
}