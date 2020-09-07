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
import AWSDK
import UserNotifications

public extension Notification.Name {
    static let AWSDKInitialized = Notification.Name("com.air-watch.sdk.initialized")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AWControllerDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Get the singleton instance for the Workspace ONE SDK's Controller.
        let controller = AWController.clientInstance()
        
        // Set callback scheme(URL Scheme) that Workspace ONE SDK should use to communication with Workspace ONE anchor applications.
        // This callback scheme should be one of the supported URL Schemes by this application.
        // This string should match with the entry in the info.plist.
        // Replace this with one of your application's supported URL Schemes.
        controller.callbackScheme = "iosswiftsample"

        // Set the delegate for Workspace ONE SDK's Controller. This delegate will recieve events from Workspace ONE SDK as callbacks.
        controller.delegate = self

        // Register for push notifications
        registerForPushNotifications()

        // Finally. Start the Workspace ONE SDK.
        // Note: You need to start Workspace ONE SDK's Controller at most once per application launch.
        // Workspace ONE SDK's Controller will monitor for the application lifecycle and refreshes access, authorization.
        // So starting Workspace ONE SDK everytime just duplicates this and may not look nice from UI perspective as well.
        controller.start()
        AWLogVerbose("Starting Workspace ONE SDK")

        // Update schemaVersion every time the schema is changed, +1
        let config = Realm.Configuration(
             schemaVersion: 2,
             migrationBlock: { migration, oldSchemaVersion in
                     if (oldSchemaVersion < 2) {}
             })
        Realm.Configuration.defaultConfiguration = config

        AFNetworkReachabilityManager.shared().startMonitoring()

        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // `AWController.handleOpenURL` method will reconnect the Workspace ONE SDK back to its previous state to continue.
        // If you are handling application specific URL schemes. Please make sure that the URL is not intended for Workspace ONE SDK's Controller.
        // An example way to perform this.
        let handedBySDKController = AWController.clientInstance().handleOpenURL(url, fromApplication: sourceApplication)
        if handedBySDKController  {
            AWLogInfo("Handed over open URL to AWController")
            // Workspace ONE SDK's Controller will continue with the result from Open URL.
            return true
        }

        // Handle if this URL is for the Application.
        return false
    }
    
    // MARK: - AWSDKDelegate

    func controllerDidFinishInitialCheck(error: NSError?) {
        if let error = error {
            AWLogError("Application recieved initial check Error: \(error)")
        } else {
            AWLogInfo("Controller did complete initial check.")
        }

        NotificationCenter.default.post(name: .AWSDKInitialized, object: error)
    }

    func controllerDidReceive(profiles: [Profile]) {
        // This method to designed to provide a profile for application immediately after the controller has recieved
        //
        //
        // Usually, Applications receive Workspace ONE SDK Settings as a Profile.
        // Application will receive a profile updated by admin according to the following rules.
        //  1. When App is being launched for the first time.
        //  2. When Application is being killed and relaunched (cold-boot).
        //  3. After launched from the background and the last profile updated was more than 4 hours ago.
        //
        // In other cases, the cached profile will be returned through this method.
        //
        // Note: First time install and launch of the application requires a profile to be available.
        // Otherwise Workspace ONE SDK's Controller Start process will be halted and will be reported as an error.
        // Generally, this method will be called after `controllerDidFinishInitialCheck(error:)` except in
        // the instance of first time launch of the application.
        //
        AWLogVerbose("Workspace ONE SDK recieved \(profiles.count) profiles.")

        guard profiles.count > 0 else {
            AWLogError("No profile received")
            return
        }

        AWLogInfo("Now printing profiles received: \n")
        profiles.forEach { AWLogInfo("\(String(describing: $0))") }
    }

    func controllerDidReceive(enrollmentStatus: AWSDK.EnrollmentStatus) {
        // This optional method will be called when enrollment status si retrieved from Workspace ONE console.
        // You will receive one of the following.
        //      When Device was never enrolled:
        //        `deviceNotFound`:
        //
        //      When device is in process of enrollment:
        //        'discovered'
        //        'registered'
        //        'enrollmentInProgress'
        //
        //      When device is enrolled and compliant:
        //        'enrolled'
        //
        //      When device is unenrolled or detected as non-compliant:
        //        `enterpriseWipePending`
        //        `deviceWipePending`
        //        `retired`
        //        `unenrolled`
        //      When network is not reachable or server sends a status that can not be parsed to one of the above.
        //         `unknown`
        AWLogInfo("Current Enrollment Status: \(String(describing: enrollmentStatus))")
    }

    func controllerDidWipeCurrentUserData() {
        // Please check for this method to handle cases when this device was unenrolled, or user tried to unlock with more than allowed attempts,
        // or other cases of compromised device detection etc. You may recieve this callback at anytime during the app run.
        AWLogError("Application should wipe all secure data")
    }

    func controllerDidLockDataAccess() {
        // This optional method will give opportunity to prepare for showing lock screen and thus saving any sensitive data
        // before showing lock screen. This method requires your admin to set up authentication type as either passcode or
        // username/password.
        AWLogInfo("Controller did lock data access.")
    }

    func controllerWillPromptForPasscode() {
        // This optional method will be called right before showing unlock screen. It is intended to take care of any UI related changes
        // before Workspace ONE SDK's Controller will present its screens. This method requires your admin to set up authentication type as either passcode or
        // username/password.
        AWLogInfo("Controller did lock data access.")
    }

    func controllerDidUnlockDataAccess() {
        // This method will be called once user enters right passcode or username/password on lock screen.
        // This method requires your admin to set up authentication type as either passcode or
        // username/password.
        AWLogInfo("User successfully unlocked")
    }

    func applicationShouldStopNetworkActivity(reason: AWSDK.NetworkActivityStatus) {
        // This method gets called when your admin restricts offline access but detected that the network is offline.
        // This method will also be called when admin whitelists specific SSIDs that this device should be connected while using this
        // application and user is connected to different/non-whitelisted WiFi network.
        //
        // Application should look this callback and stop making any network calls until recovered. Look for `applicationCanResumeNetworkActivity`.
        AWLogError("Workspace ONE SDK Detected that device violated network access policy set by the admin. reason: \(String(describing: reason))")
    }

    func applicationCanResumeNetworkActivity() {
        // This method will be called when device recovered from restrictions set by admin regarding network access.
        AWLogInfo("Application can resume network activity.")
    }

    /// This function asks user permission to show notifications. completion handler receives a bool denoting whether
    /// permission is granted or not.
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) {
                    granted, error in
                    print("Permission granted: \(granted)")
                    guard granted else { return }
                    self.getNotificationSettings()
            }
        } else {
            // Fallback on earlier versions
            let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            DispatchQueue.main.async {
                UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            }
        }
    }

    @available(iOS 10.0, *)
    /// This function will register for remote notifications once user allows to show push notifications.
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else {
                print("Can not register for remote notification since not authorized.")
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }

        }
    }


    /// iOS calls this function when registration for Remote notification is successful.
    ///Device token is set in this function which is received from APNs. Setting a new value of APNs initiate a call to Console, so to avoid unnessesary calls to console, assign token value to AWController only when token has really changed. Setting token to nil clears token value in console and won't be used for push notifications anymore.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        let controller = AWController.clientInstance()
        controller.APNSToken = token
    }


    /// iOS calls this function when registration for Remote notification is unsuccessful
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    
    
    
    

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    class func getTopView() -> UIView {
        let topView: UIView = AppDelegate.getTopViewController().view
        return topView
    }

    class func getTopViewController() -> UIViewController {
        let topWindow: UIWindow = UIApplication.shared.windows[0]
        var rootViewController: UIViewController = topWindow.rootViewController!
        while ((rootViewController.presentedViewController) != nil) {
            rootViewController = rootViewController.presentedViewController!
        }
        return rootViewController
    }


}

