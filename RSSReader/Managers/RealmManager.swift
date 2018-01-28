//
//  RealmManager.swift
//  RSSReader
//
//  Created by Matija Sabljak on 26/01/2018.
//  Copyright © 2018 Matija Sabljak. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class RealmManager {
    let realm = try! Realm()
    
    

    func addFeed(feedName: String, feedUrl: String){
        let model = FeedRealmModel()
        model.feedName = feedName
        model.feedUrl = feedUrl
        
        try! realm.write {
            realm.add(model)
            print("Added \(model.feedName) to Realm")
        }
    }
    
    func queryFeeds() -> [FeedRealmModel]{
        var feedsArray = [FeedRealmModel]()
        
        let allFeeds = realm.objects(FeedRealmModel.self)
        for feed in allFeeds {
            feedsArray.append(feed)
        }
        return feedsArray
    }
    
    func addDate(feedName: String, date: String) {
        let feed = realm.objects(FeedRealmModel.self).filter("feedName LIKE %@",feedName).first
        try! realm.write {
            feed?.lastStoryTime = date
        }
    }
}
