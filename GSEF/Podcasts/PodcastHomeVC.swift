//
//  PodcastHomeVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 9/6/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Alamofire

class PodcastHomeVC: UITableViewController {
    
    var fs: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = {
            let imageView = UIImageView(image: UIImage(named: "bluepurple"))
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        fs = Firestore.firestore()
        _ = retrievePodcasts()
        getPodcasts(nil)
    }
    
    @IBAction func refreshed(_ sender: UIRefreshControl) {
        getPodcasts(sender)
    }
    
    func getPodcasts(_ sender: UIRefreshControl?) {
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
        
        fs.collection("Podcasts").getDocuments { (snapshot, err) in
            guard err == nil else {
                print("ERROR: \(err!)")
                if let sender = sender {sender.endRefreshing()}
                self.showAlert(title: "Error: Could not retrieve data", message: err!.localizedDescription)
                return
            }
            guard let snapshot = snapshot else {
                if let sender = sender {sender.endRefreshing()}
                return
            }
            var temp: [Podcast] = []
            for document in snapshot.documents {
                let data = document.data()
                temp.append(Podcast(
                    title: data["title"] as! String,
                    desc: data["description"] as! String,
                    host: data["host"] as! String,
                    datePublished: (data["datePublished"] as! Timestamp).dateValue(),
                    length: data["length"] as! String,
                    spotifyLink: data["spotifyLink"] as! String,
                    anchorLink: data["anchorLink"] as! String
                ))
            }
            podcasts = temp
            podcasts.sort { (p1, p2) -> Bool in
                p1.datePublished > p2.datePublished
            }
            _ = savePodcasts()
            self.tableView.reloadData()
            if let sender = sender {sender.endRefreshing()}
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "podcastCell", for: indexPath) as! PodcastCell
        
        cell.title.text = podcasts[indexPath.row].title
        cell.desc.text = podcasts[indexPath.row].desc
        cell.datePublished.text = "Published on \(Date.toString(date: podcasts[indexPath.row].datePublished, format: "MMM d, YYYY"))"
        
        cell.backView.layer.cornerRadius = 15
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openPodcastPreview", sender: podcasts[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openPodcastPreview" {
            let vc = segue.destination as! PodcastPreviewVC
            vc.podcast = (sender as! Podcast)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var datePublished: UILabel!
}
