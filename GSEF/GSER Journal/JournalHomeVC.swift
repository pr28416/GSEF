//
//  ViewController.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/9/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Alamofire

class JournalHomeVC: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalCell", for: indexPath) as! JournalCell
        cell.title.text = journals[indexPath.row].title
        cell.editor.text = "Chief Editor: \(journals[indexPath.row].editor)"
        cell.desc.text = journals[indexPath.row].desc
//        cell.backView.layer.cornerRadius = 12
        cell.numArticles.layer.cornerRadius = 12
        cell.numArticles.layer.masksToBounds = true
        cell.numArticles.text = "\(journals[indexPath.row].articles.count)"
        
        
        cell.backgroundColor = .clear
        
        cell.layoutIfNeeded()
        cell.backView.layoutIfNeeded()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openJournal", sender: journals[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openJournal" {
            let VC = segue.destination as! ArticlesVC
            VC.journal = sender as! Journal
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.backgroundView = {
//            let imageView = UIImageView(image: UIImage(named: "deepblue"))
//            imageView.contentMode = .scaleAspectFill
//            return imageView
//        }()
        tableView.backgroundColor = UIColor(named: "List View Default")
        
        fs = Firestore.firestore()

        retrieveJournals()
        
        self.getArticles(nil)
        
        tableView.reloadData()
        
    }
    
    @IBAction func refreshChanged(_ sender: UIRefreshControl) {
        self.getArticles(sender)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    var fs: Firestore!
    var ref: DocumentReference!

    @objc func getArticles(_ sender: UIRefreshControl?) {
        
        if let sender = sender {sender.beginRefreshing()}
        
        let rm = NetworkReachabilityManager()
        rm?.startListening(onUpdatePerforming: { _ in
            if let hasWifi = rm?.isReachable, hasWifi {
                print("Has WiFi")
            } else {
                print("No WiFi")
                self.showAlert(title: "Not connected to internet", message: "You are currently not connected to the internet. Certain documents may not load from the server.")
                if let sender = sender {sender.endRefreshing()}
                return
            }
        })
        
//        else {tableView.refreshControl?.beginRefreshing()}
        fs.collection("Journals").getDocuments(completion: { (snapshot, err) in
            if let err = err {
                print("ERROR: \(err)")
                if let sender = sender {sender.endRefreshing()}
                self.showAlert(title: "Error: Could not retrieve data", message: err.localizedDescription)
//                else {self.tableView.refreshControl?.endRefreshing()}
                return
            }
            guard let snapshot = snapshot else {return}
            
            var categories: [String] = []
            for document in snapshot.documents {
                if document.documentID == "Categories" {
                    categories = document.data()["categories"] as! [String]
                }
                break
            }
            
            var tempJournals: [Journal] = []
            var i = 0
            for category in categories {
                self.fs.collection("Journals").document("Categories").collection(category).getDocuments { (query, err) in
                    if let err = err {
                        print("ERROR: \(err)")
                        if let sender = sender {sender.endRefreshing()}
                        self.showAlert(title: "Error: Could not retrieve data", message: err.localizedDescription)
//                        else {self.tableView.refreshControl?.endRefreshing()}
                        return
                    }
                    guard let query = query else {return}
                    
                    var articles: [Article] = []
                    var journal = Journal(title: "", editor: "", desc: "", articles: [])
                    
                    for document in query.documents {
                        let data = document.data()
                        
                        if document.documentID == "Details" {
                            journal = Journal(
                            title: category,
                            editor: data["chief_editor"] as! String,
                            desc: data["description"] as! String,
                            articles: [])
                        } else {
                            articles.append(Article(
                            title: data["title"] as! String,
                            editor: data["editor"] as! String,
                            text: data["text"] as! String,
                            dateCreated: (data["dateCreated"] as! Timestamp).dateValue(),
                            isDraft: false,
                            category: category
                            ))
                        }
                    }
                    journal.articles = articles
                    tempJournals.append(journal)
                    
//                    print("Added a new journal")
                    
                    i += 1
                    if i == categories.count {
                        print("Finished adding all journals")
                        tempJournals.sort { (j1, j2) -> Bool in j1.title < j2.title}
                        journals = tempJournals
                        self.tableView.reloadData()
                        if let sender = sender {sender.endRefreshing()}
//                        else {self.tableView.refreshControl?.endRefreshing()}
                        saveJournals()
                    }
                }
            }
            
        })
    }
    
}

class JournalCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var editor: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var backView: ShadowView!
    @IBOutlet weak var numArticles: UILabel!
}
