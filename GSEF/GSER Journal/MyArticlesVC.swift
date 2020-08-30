//
//  MyArticlesVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/29/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class MyArticlesVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = {
            let imageView = UIImageView(image: UIImage(named: "deepblue"))
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name("reloadTableView"), object: nil)
    }
    
    @objc func reloadTableView() {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newArticle" {
            let vc = (segue.destination as! UINavigationController).viewControllers[0] as! EditArticleVC
            vc.editMode = false
            vc.article = Article(title: "", editor: "", text: "", dateCreated: Date(), isDraft: true, category: "Behavioral Economics")
        } else if segue.identifier == "editArticle" {
            let vc = (segue.destination as! UINavigationController).viewControllers[0] as! EditArticleVC
            vc.editMode = true
            vc.article = (sender as! Article)
        }
    }
    
    func getArticles(section: Int) -> [Article] {
        _ = retrieveMyArticles()
        var articles: [Article] = []
        if section == 0 {
            for article in myArticles {
                if article.isDraft {
                    articles.append(article)
                }
            }
        } else {
            for article in myArticles {
                if !article.isDraft {
                    articles.append(article)
                }
            }
        }
        return articles
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {return}
        let a = getArticles(section: 0)
        guard a.count != 0 else {return}
        self.performSegue(withIdentifier: "editArticle", sender: a[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = getArticles(section: section).count
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
        let articles = getArticles(section: indexPath.section)
        if articles.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "blankCell", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! MyArticleCell
            cell.title.text = articles[indexPath.row].title
            cell.lastEdited.text = Date.toString(date: articles[indexPath.row].dateCreated, format: "MMM dd, YYYY")
            return cell
        }
    }

}

class MyArticleCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lastEdited: UILabel!
}
