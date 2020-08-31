//
//  EditArticleVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/29/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class EditArticleVC: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var editMode = false
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var articleField: UITextView!
    @IBOutlet weak var editorField: UITextField!
    
    @IBAction func close(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm exit", message: "Are you sure you want to leave? Your work won't be saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { (_) in
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name("reloadTableView"), object: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
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
            if editMode {
                for i in 0..<myArticles.count {
                    let a = myArticles[i]
                    if a.title == self.article.title && a.editor == self.article.editor && a.category == self.article.category && a.text == self.article.text {
                        myArticles[i] = Article(title: title, editor: editor, text: text, dateCreated: Date(), isDraft: true, category: category)
                        break
                    }
                }
            } else {
                myArticles.append(Article(title: title, editor: editor, text: text, dateCreated: Date(), isDraft: true, category: category))
            }
        }
        
        if saveMyArticles() {
            let alert = UIAlertController(title: "Draft saved", message: "Your draft has been saved.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { (_) in
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: NSNotification.Name("reloadTableView"), object: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "There was an error saving your work.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteDraft(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm deletion", message: "Are you sure you want to delete this draft? You won't be able to restore it.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            if self.editMode {
                for i in 0..<myArticles.count {
                    let a = myArticles[i]
                    if a.title == self.article.title && a.editor == self.article.editor && a.category == self.article.category {
                        myArticles.remove(at: i)
                        self.dismiss(animated: true, completion: nil)
                        _ = saveMyArticles()
                        break
                    }
                }
            }
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name("reloadTableView"), object: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submitForReview(_ sender: Any) {
        let alert = UIAlertController(title: "Feature coming soon", message: "Soon, you will be able to submit articles through this app. For now, you can simply write drafts.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
