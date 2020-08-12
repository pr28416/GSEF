//
//  MultipleChoiceVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/10/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class MultipleChoiceVC: UIViewController {
    
    enum Choice: Int {
        case A = 0
        case B = 1
        case C = 2
        case D = 3
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "AccentDark1")
        quizTitle.text = quiz.title
        backView.layer.cornerRadius = 10
        backView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        questionView.layer.cornerRadius = 10
        for button in mcqButtonView {
            button.layer.cornerRadius = 10
            button.backgroundColor = UIColor(named: "AccentDark1")
        }
        continueButton.layer.cornerRadius = 10
        startQuiz()
    }
    
    @IBOutlet weak var questionView: UIView!
    @IBOutlet var mcqButtonView: [UIView]!
    @IBOutlet var mcqButtonText: [UILabel]!
    
    @IBOutlet weak var backView: UIView!
    
    var quiz: Quiz!
    
    @IBAction func optionA(_ sender: UIButton) {
        chooseOption(for: .A)
    }
    
    @IBAction func optionB(_ sender: UIButton) {
        chooseOption(for: .B)
    }
    
    @IBAction func optionC(_ sender: UIButton) {
        chooseOption(for: .C)
    }
    
    @IBAction func optionD(_ sender: UIButton) {
        chooseOption(for: .D)
    }
    
    func startQuiz() {
        continueButton.isHidden = true
        continueButton.layer.opacity = 0
        questions = randomize(for: quiz)
        askQuestion()
    }
    
    func randomize(for set: Quiz) -> [Question] {
        var quiz = set
        for i in 0..<quiz.questions.count {
            var rand: Int
            repeat {
                rand = Int.random(in: 0..<quiz.questions.count)
            } while rand == i
            quiz.questions.swapAt(i, rand)
            quiz.answers.swapAt(i, rand)
        }
        var qu: [Question] = []
        for i in 0..<quiz.questions.count {
            qu.append(Question(
                        question: quiz.questions[i],
                        answer: quiz.answers[i]))
        }
//        print("\n______\nRandomized questions:\n______")
//        for i in qu {
//            print(i.question, " ::: ", i.answer)
//        }
        return qu
    }
    
    func askQuestion() {
        guard questions.count > 0 else {
            print("No questions left")
            return
        }
        
        // Pull out top question
        let query = questions.popLast()!
        questionLabel.text = query.question
        currentQuestion = query
        
        // Get random choices
        let rci = Int.random(in: 0..<4)
        var answers: [String] = [query.answer]
        for _ in 0..<3 {
            var tmp: Int
            repeat {
                tmp = Int.random(in: 0..<quiz.answers.count)
            } while answers.contains(quiz.answers[tmp])
            answers.append(quiz.answers[tmp])
        }
        answers.swapAt(0, rci)
        answerChoices = answers
        correctChoice = Choice(rawValue: rci)
        
        // Assign random choices to text
        for i in 0..<4 {
            mcqButtonText[i].text = "\(Array("ABCD")[i]). \(answers[i])"
        }
    }
    
    func chooseOption(for letter: Choice) {
        // Correct option selected
        if letter == correctChoice {
            print("Correct answer selected")
        }
        // Incorrect option selected
        else {
            print("Incorrect answer selected")
            mcqButtonView[letter.rawValue].backgroundColor = UIColor.systemRed
        }
        
        mcqButtonView[correctChoice.rawValue].backgroundColor = UIColor.systemGreen
        
        continueButton.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowAnimatedContent) {
            self.continueButton.layer.opacity = 100
        } completion: { _ in
            self.continueButton.layoutIfNeeded()
        }
    }
    
    @IBAction func continueQuiz(_ sender: UIButton) {
        for view in mcqButtonView {
            view.backgroundColor = UIColor(named: "AccentDark1")
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowAnimatedContent) {
            sender.layer.opacity = 0
        } completion: { _ in
            sender.layoutIfNeeded()
        }
        sender.isHidden = true
        askQuestion()
    }
    
    var correctChoice: Choice!
    var currentQuestion: Question!
    var answerChoices: [String]!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var quizTitle: UILabel!
    @IBOutlet weak var questionsRemaining: UILabel!
    
    struct Question {
        var question: String
        var answer: String
    }
    
    var questions: [Question]! {
        didSet {
            questionsRemaining.text = "\(questions.count) questions remaining"
        }
    }
}
