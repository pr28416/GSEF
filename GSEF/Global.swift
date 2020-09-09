//
//  Global.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/9/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object : Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object : Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
    
    enum ObjectSavableError: String, LocalizedError {
        case unableToEncode = "Unable to encode object into data"
        case noValue = "No data object found for the given key"
        case unableToDecode = "Unable to decode object into given type"
        
        var errorDescription: String? {rawValue}
    }
}

enum Color: String {
    case listViewDefault = "List View Default"
    case listViewInverted = "List View Inverted"
    case listCellDefault = "List Cell Default"
    case listCellInverted = "List Cell Inverted"
    case blueLabel = "Blue Label"
    case primaryBlue = "Primary Blue"
    case primaryGreen = "Primary Green"
    case primaryRed = "Primary Red"
    case primaryYellow = "Primary Yellow"
}


class ShadowView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func setup() {
        clipsToBounds = false
        backgroundColor = UIColor(named: "List Cell Default")
        layer.shadowColor = UIColor(red: 12/255, green: 21/255, blue: 38/255, alpha: 1).cgColor
        layer.shadowRadius = 4
        layer.cornerRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.15
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

class Podcast: Codable {
    var title: String
    var desc: String
    var host: String
    var datePublished: Date
    var length: String
    
    var spotifyLink: String
    var anchorLink: String
    
    init(title: String, desc: String, host: String, datePublished: Date, length: String, spotifyLink: String, anchorLink: String) {
        self.title = title
        self.desc = desc
        self.host = host
        self.datePublished = datePublished
        self.length = length
        self.spotifyLink = spotifyLink
        self.anchorLink = anchorLink
    }
}

class Journal: Codable, CustomStringConvertible {
    var description: String { return "\(title) (\(editor)) - \(articles)" }
    
    var title: String
    var editor: String
    var desc: String
    var articles: [Article]
    var id: String
    
    static func sortArticles(articles: [Article]) -> [Article] {
        return articles.sorted { (a1, a2) -> Bool in
            return a1.dateCreated > a2.dateCreated
        }
    }
    
    init(title: String, editor: String, desc: String, articles: [Article] = [], id: String = UUID().uuidString) {
        self.title = title
        self.editor = editor
        self.desc = desc
        self.articles = articles
        self.id = id
    }
}

class Article: Codable, CustomStringConvertible {
    var description: String { return "\(title) - \(editor)" }
    
    var title: String
    var editor: String
    var text: String
    var dateCreated: Date
    var isDraft: Bool
    var category: String
    var id: String
    
    init(title: String, editor: String, text: String, dateCreated: Date, isDraft: Bool, category: String, id: String = UUID().uuidString) {
        self.title = title
        self.editor = editor
        self.text = text
        self.dateCreated = dateCreated
        self.isDraft = isDraft
        self.category = category
        self.id = id
    }
    
    func update(title: String, editor: String, text: String, dateCreated: Date, isDraft: Bool, category: String) {
        self.title = title
        self.editor = editor
        self.text = text
        self.dateCreated = dateCreated
        self.isDraft = isDraft
        self.category = category
    }
}

extension Date {
    static func toString(date: Date, format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: date)
    }
}

var journals: [Journal] = []
var myArticles: [Article] = []
var quizCategories: [Quiz] = []
var podcasts: [Podcast] = []

func saveJournals() {
    let userDefaults = UserDefaults.standard
    do {
        try userDefaults.setObject(journals, forKey: "journals")
        print("Successfully saved journals")
    } catch {
        print(error.localizedDescription)
    }
}

func retrieveJournals() {
    let userDefaults = UserDefaults.standard
    do {
        journals = try userDefaults.getObject(forKey: "journals", castTo: [Journal].self)
        print("Successfully retrieved journals")
    } catch {
        print(error.localizedDescription)
    }
}

func saveQuizzes() {
    let userDefaults = UserDefaults.standard
    do {
        try userDefaults.setObject(quizCategories, forKey: "quizCategories")
        print("Successfully saved quizCategories")
    } catch {
        print(error.localizedDescription)
    }
}

func retrieveQuizzes() {
    let userDefaults = UserDefaults.standard
    do {
        quizCategories = try userDefaults.getObject(forKey: "quizCategories", castTo: [Quiz].self)
        print("Successfully retrieved quizCategories")
    } catch {
        print(error.localizedDescription)
    }
}

func saveMyArticles() -> Bool {
    let userDefaults = UserDefaults.standard
    do {
        try userDefaults.setObject(myArticles, forKey: "myArticles")
        return true
//        print("Successfully saved myArticles")
    } catch {
        print(error.localizedDescription)
        return false
    }
}

func retrieveMyArticles() -> Bool {
    let userDefaults = UserDefaults.standard
    do {
        myArticles = try userDefaults.getObject(forKey: "myArticles", castTo: [Article].self)
        return true
//        print("Successfully retrieved myArticles")
    } catch {
        print(error.localizedDescription)
        return false
    }
}

func savePodcasts() -> Bool {
    let userDefaults = UserDefaults.standard
    do {
        try userDefaults.setObject(podcasts, forKey: "podcasts")
        return true
//        print("Successfully saved myArticles")
    } catch {
        print(error.localizedDescription)
        return false
    }
}

func retrievePodcasts() -> Bool {
    let userDefaults = UserDefaults.standard
    do {
        podcasts = try userDefaults.getObject(forKey: "podcasts", castTo: [Podcast].self)
        return true
//        print("Successfully retrieved myArticles")
    } catch {
        print(error.localizedDescription)
        return false
    }
}

struct Quiz: Codable {
    var title: String
    var desc: String?
    var questions: [String]
    var answers: [String]
    var imageName: String
}

