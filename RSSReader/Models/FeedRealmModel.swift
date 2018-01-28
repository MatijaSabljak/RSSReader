//
//  FeedRealmModel.swift
//  RSSReader
//
//  Created by Matija Sabljak on 26/01/2018.
//  Copyright © 2018 Matija Sabljak. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class FeedRealmModel: Object {
    @objc dynamic var feedName = ""
    @objc dynamic var feedUrl = ""
    @objc dynamic var lastStoryTime = ""
}
