//
//  AppDelegate.swift
//  RSSReader
//
//  Created by Matija Sabljak on 26/01/2018.
//  Copyright © 2018 Matija Sabljak. All rights reserved.
//

import UIKit
import UserNotifications
import AlamofireRSSParser

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RSSResponse {

    var window: UIWindow?

    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?

    private var timer = Timer()
    
    private var feedsRealm = [FeedRealmModel]()
    
    private let realmManager = RealmManager()
    
    private let parser = RSSParser()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        // Override point for customization after application launch.
        setNotification()
        let homeViewController = FeedScreenViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("app Enter in Background mode")
        
        feedsRealm = realmManager.queryFeeds()
        parser.delegate = self
        
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
        })
       
        timer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(checkFeeds), userInfo: nil, repeats: true)
    }
    
    func setNotification(){
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .authorized) {
                //self.scheduleNotification(name: name)
            } else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { (granted, error) in
                    if let error = error {
                        print(error)
                    } else {
                        if (granted) {
                            //self.scheduleNotification(name: name)
                        }
                    }
                })
            }
        }
    }
    
    @objc private func checkFeeds(){
        print("timer on")
       
        for index in 0...feedsRealm.count-1 {
            let feed = feedsRealm[index]
            let _ = parser.parse(url: feed.feedUrl, name: feed.feedName)
        }
    }
    
    // protocol method, check every 2 minutes for new stories
    
    func response(feed: RSSFeed?, name: String) {
        for index in 0...feedsRealm.count-1 {
            let feedFromRealm = feedsRealm[index]
            if feedFromRealm.feedName == name {

                if let feed = feed {
                    if let firstFeed = feed.items.first {
                        if let date = firstFeed.pubDate {
                            let dateFormater = DateFormatter()
                            dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            if let dateFromRealm = dateFormater.date(from: feedFromRealm.lastStoryTime) {
                                if dateFromRealm < date {
                                    scheduleNotification(name: feedFromRealm.feedName)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func scheduleNotification(name: String){
        let content = UNMutableNotificationContent()
        content.title = "New feed"
        content.body = "\(name) has new story"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: "notif", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            } else {
                print("Notification scheduled!")
            }
        })
    }


}

