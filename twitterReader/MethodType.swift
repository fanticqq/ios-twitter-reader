import Foundation

enum MethodType: CustomStringConvertible {

    case POST
    case GET

    var description: String {
        switch self {
        case .POST:
            return "POST"
        case .GET:
            return "GET"
        }
    }
}