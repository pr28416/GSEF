//
//  ArticleSubmissionVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 9/1/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit
import ActivityIndicatorController
import FirebaseFirestore

class ArticleSubmissionVC: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var gradePicker: UISegmentedControl!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var schoolField: UITextField!
    var article: Article!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func submit(_ sender: UIButton) {
        
        guard let email = emailField.text,
              email.count > 0,
              let school = schoolField.text,
              school.count > 0 else {
            showAlert(title: "Incomplete information", message: "Please enter valid details into the boxes.", style: .alert)
            return
        }
        
        let grade = ["< 9", "9", "10", "11", "12", "> 12"][gradePicker.selectedSegmentIndex]
        
        showAlert(title: "Confirm submission", message: "Are you sure you want to submit this article? You cannot retract it afterwards.", style: .alert, actions: [
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
            UIAlertAction(title: "Submit", style: .default, handler: {_ in
                let indicator = ActivityIndicatorController()
                self.present(indicator, animated: true, completion: nil)
                
                let fs = Firestore.firestore()
                fs.collection("Submissions").addDocument(data: [
                    "title": self.article.title,
                    "editor": self.article.editor,
                    "dateCreated": self.article.dateCreated,
                    "text": self.article.text,
                    "category": self.article.category,
                    "id": self.article.id,
                    "user_email": email,
                    "user_school": school,
                    "user_grade": grade
                ]) { (err) in
                    if err != nil {
                        indicator.dismiss(animated: true) {
                            self.showAlert(title: "Error", message: err!.localizedDescription, style: .alert)
                            return
                        }
                    } else {
                        self.article.isDraft = false
                        _ = saveMyArticles()
                        indicator.dismiss(animated: true) {
                            self.showAlert(title: "Finished submitting", message: "Your submission has been uploaded. Please wait a few days to see your submission on the website.", style: .alert, actions: [
                                UIAlertAction(title: "Exit", style: .default, handler: { _ in
                                    self.navigationController?.dismiss(animated: true, completion: {
                                        NotificationCenter.default.post(name: NSNotification.Name("reloadTableView"), object: nil)
                                    })
                                })
                            ])
                        }
                    }
                }
            })
        ])
    }
    
    func showAlert(title: String, message: String, style: UIAlertController.Style, actions: [UIAlertAction]? = nil, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        if let actions = actions, actions.count > 0 {
            for action in actions {
                alert.addAction(action)
            }
        } else {
            alert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: nil))
        }
        self.present(alert, animated: true, completion: completion)
    }
    
}
