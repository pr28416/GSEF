//
//  QuizCategoryVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/10/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class QuizCategoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    struct PracticeOption {
        let title: String
        let image: UIImage?
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quiz.questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCategoryTVC", for: indexPath) as! QuizCategoryTVC
        cell.term.text = quiz.questions[indexPath.row]
        cell.definition.text = quiz.answers[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return practiceOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizCell", for: indexPath) as! QuizCategoryCVC
        cell.title.text = practiceOptions[indexPath.row].title
        cell.image.image = practiceOptions[indexPath.row].image
        cell.backView.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: self.performSegue(withIdentifier: "openMultipleChoice", sender: quiz)
        case 1:
            let alert = UIAlertController(title: "More coming soon!", message: "More features will be coming soon to Practice Options!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
//        case 1: self.performSegue(withIdentifier: "openFlashcards", sender: quiz)
        default: break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openMultipleChoice" {
            let VC = (segue.destination as! UINavigationController).viewControllers[0] as! MultipleChoiceVC
            VC.quiz = (sender as! Quiz)
        }/* else if segue.identifier == "openMatching" {
            let VC = (segue.destination as! UINavigationController).viewControllers[0] as! MatchingVC
            VC.quiz = sender as! Quiz
        }*/
        else if segue.identifier == "openFlashcards" {
            let VC = (segue.destination as! UINavigationController).viewControllers[0] as! FlashcardVC
            VC.quiz = (sender as! Quiz)
        }
    }
    
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var mainBackImage: UIImageView!
    var quiz: Quiz!
    
    var practiceOptions: [PracticeOption] = [
        PracticeOption(title: "Multiple Choice", image: UIImage(systemName: "list.bullet")),
//        PracticeOption(title: "Matching", image: UIImage(systemName: "rectangle.righthalf.inset.fill.arrow.right"))
//        PracticeOption(title: "Flashcards", image: UIImage(systemName: "rectangle.stack.fill"))
        PracticeOption(title: "More coming soon!", image: UIImage(systemName: "atom"))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = quiz.title
//        mainBackView.layer.cornerRadius = 20
//        mainBackView.layer.masksToBounds = true
//        mainBackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainBackView.layer.mask = {
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(roundedRect: mainBackView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
            mask.shouldRasterize = true
            mask.rasterizationScale = UIScreen.main.scale
            return mask
        }()
        mainBackView.layoutSubviews()
    }
    
}

class QuizCategoryTVC: UITableViewCell {
    @IBOutlet weak var term: UILabel!
    @IBOutlet weak var definition: UILabel!
}

class QuizCategoryCVC: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!
}
