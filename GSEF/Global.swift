//
//  Global.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/9/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import Foundation

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

struct Journal: Codable {
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

struct Article: Codable {
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

var journals: [Journal] = []
var quizCategories: [Quiz] = []

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

struct Quiz: Codable {
    var title: String
    var desc: String?
    var questions: [String]
    var answers: [String]
    var imageName: String
}

var tempQuestions = [
    "Bar Chart",
    "Behavioral Economics",
    "Budget Constraint",
    "Causation",
    "Comparative Statics",
    "Correlation",
    "Cost-Benefit Analysis",
    "Dependent Variable",
    "Economic Agent",
    "Economics",
    "Empirical Evidence",
    "Empiricism",
    "Equilibrium",
    "Experiment",
    "Experimental Design",
    "Experimental Economics",
    "Hypothesis",
    "Independent Variable",
    "Macroeconomics",
    "Marginal Analysis",
    "Microeconomics",
    "Model",
    "Natural Experiment",
    "Negative Correlation",
    "Normative Economics",
    "Omitted Variable",
    "Opportunity Cost",
    "Optimization at the Margin",
    "Optimization in Difference",
    "Optimization in Levels",
    "Optimization",
    "Optimum",
    "Positive Correlation",
    "Positive Economics",
    "Randomization",
    "Reverse Causality",
    "Scarce Resources",
    "Scarcity",
    "Scientific Method",
    "Trade-Off",
    "Zero Correlation"
]

var tempAnswers = [
    "chart using bars of different heights or lengths to indicate properties of different groups.",
    "branch of economics studying economic and psychological factors that explain human behavior and decisionmaking.",
    "limit on consumption bundles that consumer can afford.",
    "occurs when one variable directly affects another through cause-and-effect relationship.",
    "comparison of economic outcomes before and after some economic variable is changed.",
    "occurs when one variable and another variable have mutual relationship.",
    "calculation adding up costs and benefits using common unit of measurement, such as currency.",
    "outcome factor from manipulating a variable.",
    "individual or group that makes choices.",
    "study of how agents choose to allocate scarce resources and how those choices affect society.",
    "set of facts established by observation and measurement.",
    "analysis using data to test theories.",
    "situation in which all are simultaneously optimizing, so no one would benefit personally by changing their own behavior.",
    "controlled method of investigating causal relationships among variables.",
    "design determining how participants are assigned to different groups in experiments.",
    "branch of economics that applies experimental methods to economic questions for testing theories and creating models.",
    "prediction usually generated by model that can be tested with data.",
    "experimental factor that is manipulated.",
    "study of aggregate economy at regional, national, and international levels.",
    "cost-benefit calculation studying differences between feasible alternative and next feasible alternative.",
    "study of how individuals, households, firms, and governments make decisions, and how these decisions affect prices, resource allocation, and others.",
    "simplified description or representation of the world often using data.",
    "empirical study in which some process out of the experimenter's control has assigned subjects to control and treatment groups in random way.",
    "occurs when two variables tend to move in opposite directions.",
    "analysis prescribing what individual or society ought to do based on morals or ethics.",
    "variable left out of study that, if included, would explain why two variables in the study are correlated.",
    "best alternative use of resource.",
    "principle that optimal feasible alternative has property that moving to it makes one better off and moving away from it makes one worse off.",
    "calculates change in net benefits when individual switches from one alternative to another, using these marginal comparisons to choose the best alternative.",
    "calculates total net benefit of different alternatives, choosing the best alternative.",
    "choosing best feasible option given available information.",
    "best feasible choice.",
    "occurs when two variables tend to move in the same direction.",
    "analysis generating objective descriptions or predictions about the world that can be verified with data.",
    "assignment of subjects b chance rather than by choice to treatment or control group.",
    "occurs when direction of cause and effect is confused in a study.",
    "things that individuals want, where quantity that they want exceeds quantity available.",
    "having unlimited wants in world with limited resources.",
    "ongoing process used by economists to develop models and test those models with data.",
    "occurs when economic agent must give up one thing for something else.",
    "occurs when two variables have unrelated movements."
]
