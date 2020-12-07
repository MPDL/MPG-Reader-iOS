//
//  AppDelegate.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/7.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import RealmSwift
import AFNetworking
import Bugly

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.


        // Update schemaVersion every time the schema is changed, +1
        let config = Realm.Configuration(
             schemaVersion: 3,
             migrationBlock: { migration, oldSchemaVersion in
                     if (oldSchemaVersion < 3) {}
             })
        Realm.Configuration.defaultConfiguration = config
        Bugly.start(withAppId: "497035eca0")

        // AFNetworkReachabilityManager
        manager.startMonitoring()

        // initialize swizzle methods
        UIViewController.initializeMethod()

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

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }

    class func getTopView() -> UIView {
        let topView: UIView = AppDelegate.getTopViewController().view
        return topView
    }

    // deprecated
    class func getTopViewController() -> UIViewController {
        let topWindow: UIWindow = UIApplication.shared.windows[0]
        var rootViewController: UIViewController = topWindow.rootViewController!
        while ((rootViewController.presentedViewController) != nil) {
            rootViewController = rootViewController.presentedViewController!
        }
        return rootViewController
    }


}

