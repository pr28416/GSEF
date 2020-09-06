//
//  PodcastPreviewVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 9/6/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class PodcastPreviewVC: UIViewController {
    
    var podcast: Podcast!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var backBlur: UIVisualEffectView!
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func exit() {self.dismiss(animated: true, completion: nil)}
    
    override func viewWillLayoutSubviews() {
        for i in circleIcons {
            i.layer.cornerRadius = i.bounds.width/2
        }
        for i in backViews {
            i.layer.cornerRadius = 20
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backBlur.layer.masksToBounds = true
        backBlur.layer.cornerRadius = 20
        backBlur.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backBlur.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exit)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = podcast.title
        descLabel.text = podcast.desc
        publishedLabel.text = Date.toString(date: podcast.datePublished, format: "MMM d, YYYY")
        timeLabel.text = podcast.length
        view.isOpaque = false
    }
    @IBOutlet var circleIcons: [UIImageView]!
    
    @IBOutlet var backViews: [UIView]!
    
    @IBAction func openSpotify(_ sender: UIButton) {
        openLink(podcast.spotifyLink)
    }
    
    @IBAction func openAnchor(_ sender: UIButton) {
        openLink(podcast.anchorLink)
    }
    
    func openLink(_ link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
}
