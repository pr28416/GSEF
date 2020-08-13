//
//  MatchingVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/12/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class MatchingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0: return currentQuestions.count
        case 1: return currentAnswers.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell") as! QuestionCell
            cell.backView.layer.cornerRadius = 10
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell") as! AnswerCell
            cell.backView.layer.cornerRadius = 10
            return cell
        default: return UITableViewCell()
        }
    }
    
    @IBOutlet weak var questionTableView: UITableView!
    @IBOutlet weak var answerTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTableView.tag = 0
        answerTableView.tag = 1
    }
    
    var quiz: Quiz!
    
    var currentQuestions: [String] = []
    var currentAnswers: [String] = []

}

class QuestionCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var backView: UIView!
}

class AnswerCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var backView: UIView!
}
