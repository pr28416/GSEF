//
//  MyArticlesVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/29/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class MyArticlesVC: UITableViewController {
    
    var submittedArticles: [Article] = []
    var draftArticles: [Article] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = {
            let imageView = UIImageView(image: UIImage(named: "deepblue"))
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name("reloadTableView"), object: nil)
        
        refreshArticles()
    }
    
    @objc func reloadTableView() {
        refreshArticles()
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        refreshArticles()
        sender.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "newArticle":
            let vc = (segue.destination as! UINavigationController).viewControllers[0] as! EditArticleVC
            vc.editMode = false
            vc.article = Article(title: "", editor: "", text: "", dateCreated: Date(), isDraft: true, category: "Behavioral Economics")
            myArticles.append(vc.article)
        case "editArticle":
            let vc = (segue.destination as! UINavigationController).viewControllers[0] as! EditArticleVC
            vc.editMode = true
            vc.article = (sender as! Article)
        case "openFinishedArticle":
            let vc = segue.destination as! OpenArticleVC
            vc.article = (sender as! Article)
            vc.isPublished = false
        default: break
        }
    }
    
    func refreshArticles() {
        _ = retrieveMyArticles()
        draftArticles = []
        submittedArticles = []
        for article in myArticles {
            if article.isDraft {
                draftArticles.append(article)
            } else {
                submittedArticles.append(article)
            }
        }
        print("Draft articles:", draftArticles)
        print("Submitted articles:", submittedArticles)
        _ = saveMyArticles()
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard draftArticles.count != 0 else {return}
            self.performSegue(withIdentifier: "editArticle",
                              sender: draftArticles[indexPath.row])
        case 1:
            guard submittedArticles.count != 0 else {return}
            self.performSegue(withIdentifier: "openFinishedArticle",
                              sender: submittedArticles[indexPath.row])
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count: Int
        switch section {
        case 0: count = draftArticles.count
        case 1: count = submittedArticles.count
        default: return 1
        }
        return count == 0 ? 1 : count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Drafts", "Submissions"][section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let text = view as! UITableViewHeaderFooterView
        text.textLabel?.textColor = .white
        let attributedText = NSMutableAttributedString(string: text.textLabel?.text ?? "", attributes: [
            NSAttributedString.Key.paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }(),
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)
        ])
        text.textLabel?.attributedText = attributedText
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let articles: [Article]
        switch indexPath.section {
        case 0: articles = draftArticles
        case 1: articles = submittedArticles
        default: return tableView.dequeueReusableCell(withIdentifier: "blankCell", for: indexPath)
        }
        
        if articles.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "blankCell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! MyArticleCell
        cell.title.text = articles[indexPath.row].title
        cell.lastEdited.text = Date.toString(date: articles[indexPath.row].dateCreated, format: "MMM dd, YYYY")
        return cell
    }

}

class MyArticleCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lastEdited: UILabel!
}
