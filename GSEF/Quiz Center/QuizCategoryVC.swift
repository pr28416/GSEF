//
//  QuizCategoryVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/10/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class QuizCategoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
//        cell.backView.layer.cornerRadius = 20
        
//        cell.layer.cornerRadius = 20
//        cell.layer.shadowColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1).cgColor
//        cell.layer.shadowOffset = CGSize(width: 0, height: 8)
//        cell.layer.shadowRadius = 20
//        cell.layer.shadowOpacity = 0.25
//        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 20).cgPath
//        cell.layer.masksToBounds = false
        cell.backgroundColor = UIColor.new(named: .primaryBlue)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: self.performSegue(withIdentifier: "openMultipleChoice", sender: quiz)
        case 1: self.performSegue(withIdentifier: "openTypingTest", sender: quiz)
        default:
            let alert = UIAlertController(title: "More coming soon!", message: "More features will be coming soon to Practice Options!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openMultipleChoice" {
            let VC = (segue.destination as! UINavigationController).viewControllers[0] as! MultipleChoiceVC
            VC.quiz = (sender as! Quiz)
        } else if segue.identifier == "openTypingTest" {
            let VC = (segue.destination as! UINavigationController).viewControllers[0] as! TypingTestVC
            VC.quiz = (sender as! Quiz)
        }
    }
    
    @IBOutlet weak var mainBackView: ShadowView!
    var quiz: Quiz!
    
    var practiceOptions: [PracticeOption] = [
        PracticeOption(title: "Multiple Choice", image: UIImage(systemName: "list.bullet")),
        PracticeOption(title: "Typing Test", image: UIImage(systemName: "keyboard")),
        PracticeOption(title: "More coming soon!", image: UIImage(named: "app_atom"))
    ]
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = quiz.title
        
        view.backgroundColor = UIColor.new(named: .listViewDefault)
    }
    
    override func viewDidLayoutSubviews() {
        mainBackView.layer.shadowPath = UIBezierPath(roundedRect: mainBackView.bounds, cornerRadius: 20).cgPath
    }
    
}

class QuizCategoryTVC: UITableViewCell {
    @IBOutlet weak var term: UILabel!
    @IBOutlet weak var definition: UILabel!
}

class QuizCategoryCVC: ShadowCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!
}
