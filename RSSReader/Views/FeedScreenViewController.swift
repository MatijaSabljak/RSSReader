//
//  FeedScreenViewController.swift
//  RSSReader
//
//  Created by Matija Sabljak on 26/01/2018.
//  Copyright © 2018 Matija Sabljak. All rights reserved.
//

import UIKit
import AlamofireRSSParser

class FeedScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let myArray: NSArray = ["First","Second","Third"]
    private var myTableView: UITableView!
    
    private var feeds = [FeedRealmModel]()
    
    private let realmManager = RealmManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllerAndTableView()
        feeds = realmManager.queryFeeds()
        if feeds.count == 0 {
            initialLoadOfFeeds(name: "24 Sata Sport", url: "https://www.24sata.hr/feeds/sport.xml")
            initialLoadOfFeeds(name: "HRT sport", url: "http://www.hrt.hr/rss/sport/")
            initialLoadOfFeeds(name: "Index", url: "http://www.index.hr/najnovije/rss.ashx")
            self.myTableView.reloadData()
        }
        autoLayout()
    }
    
    func autoLayout(){
        self.myTableView.translatesAutoresizingMaskIntoConstraints = false
        self.myTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.myTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.myTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.myTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        
    }
    
    func initialLoadOfFeeds(name: String, url: String){
        let feed = FeedRealmModel()
        feed.feedName = name
        feed.feedUrl = url
        self.feeds.append(feed)
        self.realmManager.addFeed(feedName: name, feedUrl: url)
    }

    
    func setupViewControllerAndTableView(){
        self.title = "Feeds"
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.separatorStyle = .none
        self.view.addSubview(myTableView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    

    // add new feed
    @objc func addTapped(){

        let alertController = UIAlertController(title: "Enter new feed", message: "Please enter your feed and url", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            if let name = alertController.textFields?[0].text, let url = alertController.textFields?[1].text {
                let feed = FeedRealmModel()
                feed.feedName = name
                feed.feedUrl = url
                self.feeds.append(feed)
                self.myTableView.reloadData()
                self.realmManager.addFeed(feedName: name, feedUrl: url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter feed name"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter feed url"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myViewController = StoriesScreenViewController(nibName: "StoriesScreenViewController", bundle: nil)
        myViewController.url = feeds[indexPath.row].feedUrl
        myViewController.name = feeds[indexPath.row].feedName
        self.navigationController!.pushViewController(myViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = feeds[indexPath.row].feedName
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
        } else {
            cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.2)
        }

        return cell
    }
}
