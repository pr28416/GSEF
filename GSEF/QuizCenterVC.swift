//
//  ResourceGuideHomeVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/10/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit
import FirebaseFirestore

class QuizCenterVC: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizCategories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCenterCell", for: indexPath) as! QuizCenterCell
        cell.backView.layer.cornerRadius = 10
        cell.title.text = quizCategories[indexPath.row].title
        // Later put in cell description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openQuiz", sender: quizCategories[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openQuiz" {
            let VC = segue.destination as! QuizCategoryVC
            VC.quiz = sender as! Quiz
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fs = Firestore.firestore()
        getQuizzes(nil)
    }
    
    @objc func getQuizzes(_ sender: UIRefreshControl?) {
        if let sender = sender {sender.beginRefreshing()}
        fs.collection("Quizzes").getDocuments { (snapshot, err) in
            if let err = err {
                print("ERROR: \(err)")
                if let sender = sender {sender.endRefreshing()}
                return
            }
            guard let snapshot = snapshot else {return}
            var tempCategories: [Quiz] = []
            var i = 0
            for document in snapshot.documents {
                i += 1
                let data = document.data()
                print("Adding quiz")
                tempCategories.append(
                    Quiz(
                        title: data["Title"] as! String,
                        desc: nil,
                        questions: data["Questions"] as! [String],
                        answers: data["Answers"] as! [String]
                    ))
                if i >= snapshot.documents.count {
                    print("Finished getting quizzes")
                    if let sender = sender {sender.endRefreshing()}
                    self.quizCategories = tempCategories
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    var quizCategories: [Quiz] = []
    
    @IBAction func refreshChanged(_ sender: UIRefreshControl) {
        getQuizzes(sender)
    }
    
    var ref: DocumentReference?
    var fs: Firestore!

}

class QuizCenterCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var title: UILabel!
    
}
