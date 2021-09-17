//
//  AppDelegate.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import Firebase
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
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
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

  
}

