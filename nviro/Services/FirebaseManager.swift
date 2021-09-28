//
//  FirebaseManager.swift
//  nviro
//
//  Created by Ali Dinç on 28/09/2021.
//

import Foundation
import Firebase

final class FirebaseManager {
    
    func setupFirebase() {
        
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true


        // Enable offline data persistence
        let db = Firestore.firestore()
        db.settings = settings
        
        // The default cache size threshold is 100 MB. Configure "cacheSizeBytes"
        // for a different threshold (minimum 1 MB) or set to "FirestoreCacheSizeUnlimited"
        // to disable clean-up.
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
    
        let userID = UIDevice.current.identifierForVendor!.uuidString
        UserDefaults.standard.set(userID, forKey: "user")
        
    }
    
    
    static let shared = FirebaseManager()
    let db = Firestore.firestore()
    let user = UserDefaults.standard.string(forKey: "user")
    
    
    
}
