//
//  Parser.swift
//  RSSReader
//
//  Created by Matija Sabljak on 26/01/2018.
//  Copyright © 2018 Matija Sabljak. All rights reserved.
//

import Alamofire
import AlamofireRSSParser
import SwiftyJSON

protocol RSSResponse {
    func response(feed: RSSFeed?, name: String)
}

public class RSSParser {
    
    var delegate: RSSResponse?
    
    public func parse(url: String, name: String) -> RSSFeed? {
        var feedToReturn: RSSFeed?
        Alamofire.request(url).responseRSS() { (response) -> Void in
            if let feed = response.result.value {
                for item in feed.items {
                    print(item)
                }
                feedToReturn = feed
                self.delegate?.response(feed: feed, name: name)
            }
        }
        return feedToReturn
    }
}

