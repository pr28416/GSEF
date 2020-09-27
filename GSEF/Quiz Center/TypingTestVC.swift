//
//  TypingTest.swift
//  GSEF
//
//  Created by Pranav Ramesh on 9/26/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class TypingTestVC: UIViewController, UITextFieldDelegate {
    
    var quiz: Quiz!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryBar: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var yourAnswerLabel: UILabel!
    @IBOutlet weak var correctGlyph: UIImageView!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var userAnswerLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var resultPanel: ShadowView!
    @IBOutlet weak var resultStack: UIStackView!
//    @IBOutlet var backViews: [ShadowView]!
    
    @IBOutlet weak var questionsCorrect: UILabel!
    @IBOutlet weak var questionsIncorrect: UILabel!
    @IBOutlet weak var questionsRemaining: UILabel!
    var score: Int! { didSet { questionsCorrect.text = "\(score ?? 0)" } }
    var incorrectCount: Int! { didSet { questionsIncorrect.text = "\(incorrectCount ?? 0)" } }
    
//    override func viewDidLayoutSubviews() {
//        for i in backViews {
//            i.layer.cornerRadius = 16
//            i.layer.shadowPath = UIBezierPath(roundedRect: i.bounds, cornerRadius: 16).cgPath
//        }
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = UIColor(named: "Primary Blue")
        categoryLabel.text = quiz.title
        categoryBar.layer.cornerRadius = 16
        categoryBar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        isModalInPresentation = true
        navigationController?.isModalInPresentation = true
        answerField.delegate = self
        continueButton.layer.cornerRadius = 12
        startQuiz()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
//        processAnswer()
        return true
    }
    
    @IBAction func closeQuiz(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm exit", message: "Are you sure you want to leave? Your progress won't be saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    var questions: [Question] = []
    var currentQuestion: Question!
    
    func startQuiz() {
        score = 0
        incorrectCount = 0
        questionsRemaining.text = "\(quiz.questions.count-score-incorrectCount)"
        progressBar.progress = 0
        questions = []
        for q in 0..<quiz.questions.count {
            questions.append(Question(question: quiz.answers[q], answer: quiz.questions[q]))
        }
        askQuestion()
    }
    
    func askQuestion() {
        guard questions.count > 0 else { endTest(); return }
        progressBar.progress = Float(quiz.questions.count-questions.count)/100.0
        resultStack.isHidden = true
        submitButton.isEnabled = true
        answerField.isEnabled = true
        answerField.text = ""
        currentQuestion = questions.remove(at: Int.random(in: 0..<questions.count))
        questionLabel.text = currentQuestion.question
    }
    
    var correctStatus = false
    
    func processAnswer() {
        guard var userAnswer = answerField.text, userAnswer.count > 0 else {return}
        toggleResultsPanel(show: true)
        
        correctAnswerLabel.text = currentQuestion.answer
        userAnswerLabel.text = userAnswer
        
        let punctuation = Set<Character>("!@#$%^&*(){}[]\\'\";:?/.,><`~ ")
        var cAns = currentQuestion.answer.lowercased()
        userAnswer.removeAll(where: {punctuation.contains($0)})
        userAnswer = userAnswer.lowercased()
        
        var abv = String()
        if let lo = cAns.firstIndex(of: "("), let up = cAns.firstIndex(of: ")") {
            abv = String(cAns[lo...up]).lowercased()
        }
        abv.removeAll(where: {punctuation.contains($0)})
        
        var noAbv = String(cAns)
        if let lo = cAns.firstIndex(of: "("), let up = cAns.firstIndex(of: ")") {
            noAbv.removeSubrange(lo...up)
        }
        
        cAns.removeAll(where: {punctuation.contains($0)})
        noAbv.removeAll(where: {punctuation.contains($0)})
        
        correctStatus = userAnswer == cAns || userAnswer == abv || userAnswer == noAbv
        if correctStatus {
            yourAnswerLabel.textColor = UIColor(named: "Primary Green")
            correctGlyph.tintColor = UIColor(named: "Primary Green")
            correctGlyph.image = UIImage(systemName: "checkmark")
        } else {
            yourAnswerLabel.textColor = UIColor(named: "Primary Red")
            correctGlyph.tintColor = UIColor(named: "Primary Red")
            correctGlyph.image = UIImage(systemName: "xmark")
        }
    }
    
    @IBAction func continuePressed(_ sender: UIButton) {
        if correctStatus {
            score += 1
        } else {
            incorrectCount += 1
        }
        questionsRemaining.text = "\(quiz.questions.count-score-incorrectCount)"
        toggleResultsPanel(show: false)
        askQuestion()
    }
    
    @IBAction func overrideAnswer(_ sender: UIButton) {
        score += 1
        questionsRemaining.text = "\(quiz.questions.count-score-incorrectCount)"
        toggleResultsPanel(show: false)
        askQuestion()
    }
    
    func toggleResultsPanel(show: Bool) {
        submitButton.isEnabled = !show
        answerField.isEnabled = !show
        if show {
            resultStack.alpha = 0
            resultStack.isHidden = false
            UIView.animate(withDuration: 0.6) {
                self.resultStack.alpha = 1
            } completion: { _ in
                self.resultStack.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }
        } else {
            resultStack.alpha = 1
            UIView.animate(withDuration: 0.6) {
                self.resultStack.alpha = 0
            } completion: { _ in
                self.resultStack.layoutIfNeeded()
                self.view.layoutIfNeeded()
                self.resultStack.isHidden = true
            }
        }
    }
    
    @IBAction func submitPressed(_ sender: UIButton) { processAnswer() }
    
    func endTest() {
        let alert = UIAlertController(title: "Finished test", message: "You finished this test! Your score was \(score ?? 0) out of \(quiz.questions.count)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    struct Question {
        var question: String
        var answer: String
    }
}
