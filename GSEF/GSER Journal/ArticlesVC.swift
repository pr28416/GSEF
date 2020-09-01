//
//  ArticlesVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/9/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class ArticlesVC: UITableViewController {
    
    var journal: Journal!
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journal.articles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        cell.title.text = journal.articles[indexPath.row].title
        cell.editor.text = journal.articles[indexPath.row].editor
        cell.dateCreated.text = "Published on \(Date.toString(date: journal.articles[indexPath.row].dateCreated, format: "MMM d, YYYY"))"
        cell.backImage.layer.cornerRadius = 12
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openArticle", sender: journal.articles[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openArticle" {
            let VC = segue.destination as! OpenArticleVC
            VC.article = sender as! Article
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = journal.title
        tableView.backgroundView = {
            let imageView = UIImageView(image: UIImage(named: "deepblue"))
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        journal.articles = Journal.sortArticles(articles: journal.articles)
    }
    
}

class OpenArticleVC: UIViewController {
    
    var article: Article!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleEditor: UILabel!
    @IBOutlet weak var articleDateCreated: UILabel!
    @IBOutlet weak var articleText: UITextView!
    var isPublished = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articleTitle.text = article.title
        articleEditor.text = "Editor: \(article.editor)"
        articleDateCreated.text = "\(isPublished ? "Published" : "Submitted") on \(Date.toString(date: article.dateCreated, format: "MMM d, YYYY"))"
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 15
        articleText.attributedText = NSAttributedString(string: article.text.replacingOccurrences(of: "  ", with: "\n\n"), attributes: [
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: UIColor.label
        ])
        
        let width = articleText.frame.size.width
        let newSize = articleText.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        articleText.frame.size = CGSize(width: max(newSize.width, width), height: newSize.height)
        
    }
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var editor: UILabel!
    @IBOutlet weak var dateCreated: UILabel!
}
