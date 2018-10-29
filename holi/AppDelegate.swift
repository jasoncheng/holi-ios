//
//  AppDelegate.swift
//  holi
//
//  Created by jasoncheng on 2018/10/20.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase
        FirebaseApp.configure()
        
        // Tab 控制
        let tabC = UITabBarController()
        let tabMy = UINavigationController(rootViewController: TabMyVC())
        tabMy.tabBarItem = UITabBarItem(title: NSLocalizedString("TabMy", comment: ""), image: UIImage(named: "icons/tab_person"), tag: 100)
        let tabPublish = UINavigationController(rootViewController: TabPublishVC())
        tabPublish.tabBarItem = UITabBarItem(title: NSLocalizedString("TabPublish", comment: ""), image: UIImage(named: "icons/tab_publish"), tag: 200)
        let tabRecommend = UINavigationController(rootViewController: TabRecommendVC())
        tabRecommend.tabBarItem = UITabBarItem(title: NSLocalizedString("TabRecommend", comment: ""), image: UIImage(named: "icons/tab_star"), tag:300)
        tabC.viewControllers = [tabMy, tabPublish, tabRecommend]
        
        // Window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.rootViewController = tabC
        self.window?.makeKeyAndVisible()
        tabC.selectedIndex = 0
        
        // User Process
        let user = Auth.auth().currentUser
        if let user = user {
//            let userid = user.uid
//            let username = user.displayName
//            let useremail = user.email
            print("=========> welcome user \(user.uid)")
        } else {
            Auth.auth().signInAnonymously{(user, error) in
                if error != nil {
                    print("Error \(String(describing: error))")
                } else {
                    print(user)
                }
            }
        }
        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

