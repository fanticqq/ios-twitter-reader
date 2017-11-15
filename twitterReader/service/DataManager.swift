import UIKit
import RealmSwift

extension Realm {
    
    static var mainRealm = try! Realm()
    
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
    
    static func realmWrite(realm: Realm = mainRealm, _ block: (() -> Void)) {
        realm.realmWrite(block)
    }
}
