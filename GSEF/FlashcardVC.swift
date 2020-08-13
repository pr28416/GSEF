//
//  FlashcardVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/12/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class FlashcardVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    @IBOutlet weak var pageView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "AccentDark1")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedChildSegue" {
            if let child = segue.destination as? FlashcardContainer {
                child.quiz = quiz
            }
        }
    }
    
    struct Question {
        var question: String
        var answer: String
    }
    
    var quiz: Quiz!
    var pages: [Question] = []
    
    @IBOutlet weak var pageControl: UIPageControl!
}

class FlashcardContainer: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var pageViews: [Flashcard] = []
    var quiz: Quiz!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        for q in 0..<quiz.questions.count {
//            let newCard = UIViewController(nibName: "Flashcard", bundle: nil) as! Flashcard
            let newCard = storyboard.instantiateViewController(identifier: "Flashcard") as Flashcard
            newCard.question = quiz.questions[q]
            newCard.answer = quiz.answers[q]
            newCard.cardIndex = q
            pageViews.append(newCard)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let card = viewController as! Flashcard
        if card.cardIndex == 0 {return nil}
        return pageViews[card.cardIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let card = viewController as! Flashcard
        if card.cardIndex == pageViews.count - 1 {return nil}
        return pageViews[card.cardIndex + 1]
    }
    
    
}
