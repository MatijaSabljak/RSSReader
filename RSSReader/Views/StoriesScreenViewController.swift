//
//  StoriesScreenViewController.swift
//  RSSReader
//
//  Created by Matija Sabljak on 26/01/2018.
//  Copyright © 2018 Matija Sabljak. All rights reserved.
//

import UIKit
import AlamofireRSSParser

class StoriesScreenViewController: UITableViewController, RSSResponse {
    
    public var url : String? = nil
    public var name : String? = nil {
        didSet{
            self.title = name
        }
    }
    
    private let parser = RSSParser()
    private var feeds: RSSFeed?
    private let realmManager = RealmManager()
    private var activityView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.center = self.view.center
        activityView.startAnimating()
        
        self.view.addSubview(activityView)

        //self.title = "Stories"
        self.tableView.register(UINib(nibName: "StoriesCell", bundle: nil), forCellReuseIdentifier: "StoriesCell")
        self.tableView.separatorStyle = .none
        
        parser.delegate = self
        if let urlToParse = url, let name = name {
            feeds = parser.parse(url: urlToParse, name: name)
        }
    }
    
    // protocol method
    func response(feed: RSSFeed?, name: String) {
        feeds = feed
       
        // save date and time of last story to data base
        if let feeds = feeds {
            if let feed = feeds.items.first {
                if let date = feed.pubDate {
                    let dateFormater = DateFormatter()
                    dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    let dateString = dateFormater.string(from: date)
                    realmManager.addDate(feedName: name, date: dateString)
                }
            }
        }
        activityView.stopAnimating()
        self.tableView.reloadData()
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let feeds = feeds {
            return feeds.items.count
        } else {
            return 0
        }
    }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesCell", for: indexPath) as! StoriesCell
    
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
        } else {
            cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.1)
        }
        if let feeds = feeds {
            cell.storyNameLabel.text = feeds.items[indexPath.row].title
            if let imageCounter = feeds.items[indexPath.row].imagesFromDescription {
                if (imageCounter.count > 0) {
                    if let urlString = feeds.items[indexPath.row].imagesFromDescription?.first {
                        if let url = NSURL(string: urlString) {
                            let data = NSData(contentsOf:url as URL)
                            var image = UIImage()
                            if (data != nil){
                                image = UIImage(data:data! as Data)!
                                cell.storyImage.image = image
                            }
                        }
                    }
                }
            }
            if let imageCounter = feeds.items[indexPath.row].imagesFromContent {
                if (imageCounter.count > 0) {
                    if let urlString = feeds.items[indexPath.row].imagesFromContent?.first {
                        if let url = NSURL(string: urlString) {
                            let data = NSData(contentsOf:url as URL)
                            var image = UIImage()
                            if (data != nil){
                                image = UIImage(data:data! as Data)!
                                cell.storyImage.image = image
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        if let urlToShow = url {
            if let url = URL(string: urlToShow) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
}
