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
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Confirm exit", message: "You haven't finished the multiple choice quiz. Do you still want to exit?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "AccentDark1")
        quizTitle.text = quiz.title
        self.isModalInPresentation = true
        backView.layer.cornerRadius = 10
        backView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        questionView.layer.cornerRadius = 10
        for button in mcqButtonView {
            button.layer.cornerRadius = 10
            button.backgroundColor = UIColor(named: "AccentDark1")
        }
        continueButton.layer.cornerRadius = 10
        palette.layer.cornerRadius = 10
        startQuiz()
    }
    
    @IBOutlet weak var questionView: UIView!
    @IBOutlet var mcqButtonView: [UIView]!
    @IBOutlet var mcqButtons: [UIButton]!
    @IBOutlet var mcqButtonText: [UILabel]!
    
    @IBOutlet weak var palette: UIView!
    
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
        progressBar.setProgress(0, animated: true)
        score = 0
        incorrectCount = 0
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
            endQuiz()
            return
        }
        
        // Pull out top question
        let query = questions.popLast()!
        questionLabel.text = query.question
        currentQuestion = query
        
        // Make buttons valid
        for button in mcqButtons {
            button.isEnabled = true
        }
        
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
        // Make buttons invalid
        for button in mcqButtons {
            button.isEnabled = false
        }
        
        progressBar.setProgress(Float(quiz.questions.count - questions.count)/Float(quiz.questions.count), animated: true)
        
        // Correct option selected
        if letter == correctChoice {
            print("Correct answer selected")
            score += 1
        }
        // Incorrect option selected
        else {
            print("Incorrect answer selected")
            incorrectCount += 1
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
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    func endQuiz() {
        let alert = UIAlertController(title: "Finished!", message: "Your score was: \(score ?? 0)/\(quiz.questions.count)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Exit", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    var score: Int! {
        didSet {
            questionsCorrect.text = "\(score ?? 0)"
        }
    }
    var incorrectCount: Int! {
        didSet {
            questionsIncorrect.text = "\(incorrectCount ?? 0)"
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
    @IBOutlet weak var questionsCorrect: UILabel!
    @IBOutlet weak var questionsIncorrect: UILabel!
    
    struct Question {
        var question: String
        var answer: String
    }
    
    var questions: [Question]! {
        didSet {
            questionsRemaining.text = "\(questions.count)"
        }
    }
}
