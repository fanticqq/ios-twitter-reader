import UIKit
import RealmSwift

class RealmController {
    
    private init() {}
    
    static var mainRealm = try! Realm()
    
    class func realmWrite(realm: Realm = mainRealm, _ block: (() -> Void)) {
        realm.realmWrite(block)
    }
}

extension Realm {
    
    func realmWrite(_ block: (() -> Void)) {
        if isInWriteTransaction {
            block()
        } else {
            do {
                try write(block)
            } catch {
                assertionFailure("Realm write error: \(error)")
            }
        }
    }
}
