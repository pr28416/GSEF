//
//  AboutVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/12/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        activateButton.layer.cornerRadius = 10
        copyright.text = "© \(Date.toString(date: Date(), format: "YYYY")) Pranav Ramesh"
    }
    
    @IBOutlet weak var activateButton: UIButton!
    @IBAction func activatePressed(_ sender: UIButton) {
        if let url = URL(string: "https://gsefofficial.org") {
            UIApplication.shared.open(url)
        }
    }
    @IBOutlet weak var copyright: UILabel!
    
}
