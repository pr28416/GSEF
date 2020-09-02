//
//  EditArticleVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/29/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit
import ActivityIndicatorController

class EditArticleVC: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverControllerDelegate {
    
    var editMode = false
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var articleField: UITextView!
    @IBOutlet weak var editorField: UITextField!
    
    @IBAction func close(_ sender: Any) {
        showAlert(title: "Confirm exit", message: "Are you sure you want to leave? Your work won't be saved.", style: .alert, actions: [
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
            UIAlertAction(title: "Exit", style: .destructive, handler: { (_) in
                self.closePage()
            })
        ])
    }
    
    let categories: [String] = ["Behavioral Economics", "Current Events", "Economic History", "Economic and Urban Geography", "Environmental Economics", "Finance", "Macroeconomics", "Microeconomics", "Political Economy and Geopolitics", "Science and Technology"]
    
    var article: Article!
    
    var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.title = "\(editMode ? "Edit" : "New") Article"
        
        titleField.text = article.title
        categoryField.text = article.category
        articleField.text = article.text
        editorField.text = article.editor
        
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        categoryField.inputView = pickerView
        categoryField.inputAccessoryView = {
            let toolbar = UIToolbar()
            toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(assignCategory))
            ]
            toolbar.sizeToFit()
            return toolbar
        }()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closePage), name: NSNotification.Name("closeArticleEditor"), object: nil)
    }
    
    @objc func closePage() {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name("reloadTableView"), object: nil)
        }
    }
    
    @objc func assignCategory() {
        categoryField.resignFirstResponder()
        if !categories.contains(categoryField.text ?? "") {
            categoryField.text = article.category
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryField.text = categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveDraft(_ sender: Any) {
        if let title = titleField.text, let category = categoryField.text, let text = articleField.text, let editor = editorField.text {
            article.update(title: title, editor: editor, text: text, dateCreated: Date(), isDraft: true, category: category)
        }
        
        if saveMyArticles() {
            showAlert(title: "Draft saved", message: "Your draft has been saved.", style: .alert, actions: [
                UIAlertAction(title: "Exit", style: .destructive, handler: { (_) in
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: NSNotification.Name("reloadTableView"), object: nil)
                    }
                }),
                UIAlertAction(title: "Continue", style: .cancel, handler: nil)
            ])
        } else {
            showAlert(title: "Error", message: "There was an error saving your work.", style: .alert)
        }
    }
    
    @IBAction func deleteDraft(_ sender: Any) {
        showAlert(title: "Confirm deletion", message: "Are you sure you want to delete this draft? You won't be able to restore it.", style: .alert, actions: [
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
            UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                myArticles.removeAll { (a) -> Bool in
                    a.id == self.article.id
                }
                saveMyArticles()
                self.closePage()
            })
        ])
    }
    

    
    @IBAction func submitForReview(_ sender: UIButton) {
        
        let indicator = ActivityIndicatorController()
        indicator.isModalInPresentation = true
        if let popoverController = indicator.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.frame
        }
        self.present(indicator, animated: true, completion: nil)
        
        print("Verifying submission...")
        
        if let title = self.titleField.text,
           title.count > 0,
           let category = self.categoryField.text,
           self.categories.contains(category),
           let text = self.articleField.text,
           text.count > 0,
           let editor = self.editorField.text,
           editor.count > 0 {
            article.update(title: title, editor: editor, text: text, dateCreated: Date(), isDraft: true, category: category)
        } else {
            print("Verification failed.")
            indicator.dismiss(animated: true) {
                self.showAlert(title: "Incomplete submission", message: "There are one or more areas that are incomplete. Make sure to fill in all the available boxes.", style: .alert)
                return
            }
        }
        
        print("Attempting to save articles...")
        
        if !saveMyArticles() {
            print("Saving failed.")
            indicator.dismiss(animated: true) {
                self.showAlert(title: "Error", message: "There was an error saving your work.", style: .alert)
                return
            }
        } else {
            indicator.dismiss(animated: true) {
                print("Proceeding to submission VC")
                
                self.performSegue(withIdentifier: "processSubmission", sender: self.article)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "processSubmission" {
            let vc = segue.destination as! ArticleSubmissionVC
            vc.article = (sender as! Article)
        }
    }
    
    /// Presents an alert to the user. If there are no actions, a "Go back" message is displayed.
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
