//
//  Global.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/9/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import Foundation

struct Journal {
    var title: String
    var editor: String
    var desc: String
    var articles: [Article]
    
    static func sortArticles(articles: [Article]) -> [Article] {
        return articles.sorted { (a1, a2) -> Bool in
            return a1.dateCreated > a2.dateCreated
        }
    }
}

struct Article {
    var title: String
    var editor: String
    var text: String
    var dateCreated: Date
}

extension Date {
    static func toString(date: Date, format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: date)
    }
}

struct Quiz {
    var title: String
    var desc: String?
    var questions: [String]
    var answers: [String]
}
