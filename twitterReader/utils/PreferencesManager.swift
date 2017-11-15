import Foundation

final class PreferencesManager {

    private static let FIELD_TOKEN = "TOKEN"

    internal static func readBearerToken() -> String? {
        return UserDefaults.standard.string(forKey: FIELD_TOKEN)
    }

    internal static func saveBearerToken(token: String) {
        UserDefaults.standard.set(token, forKey: FIELD_TOKEN)
    }
}
