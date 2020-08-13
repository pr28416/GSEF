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
        retrieveQuizzes()
        if quizCategories.count == 0 {
            getQuizzes(nil)
        }
    }
    
    @objc func getQuizzes(_ sender: UIRefreshControl?) {
        if let sender = sender {sender.beginRefreshing()}
        fs.collection("Quizzes").getDocuments { (snapshot, err) in
            if let err = err {
                print("ERROR: \(err)")
                if let sender = sender {sender.endRefreshing()}
                self.showAlert(title: "Error: Could not retrieve data", message: err.localizedDescription)
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
                    quizCategories = tempCategories
                    saveQuizzes()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
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
