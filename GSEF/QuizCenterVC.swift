//
//  ResourceGuideHomeVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/10/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit
import FirebaseFirestore

class QuizCenterVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quizCategories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizCenterCell", for: indexPath) as! QuizCenterRectCell
//        cell.backView.layer.cornerRadius = 10
        cell.layer.cornerRadius = 10
        cell.backView.backgroundColor = .clear
        cell.backgroundView = {
            let imageView = UIImageView(image: UIImage(named: "cellgray"))
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        cell.title.text = quizCategories[indexPath.row].title
        cell.icon.image = UIImage(named: quizCategories[indexPath.row].imageName)
        // Later put in cell description
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openQuiz", sender: quizCategories[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openQuiz" {
            let VC = segue.destination as! QuizCategoryVC
            VC.quiz = sender as! Quiz
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundView = {
            let imageView = UIImageView(image: UIImage(named: "bluegreen"))
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .secondaryLabel
        refreshControl.addTarget(self, action: #selector(getQuizzes(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        
//        collectionView.collectionViewLayout = {
//            let layout = UICollectionViewFlowLayout()
//            layout.minimumInteritemSpacing = 12
//            layout.minimumLineSpacing = 12
//
//            return layout
//        }()
        
        fs = Firestore.firestore()
        retrieveQuizzes()
        if quizCategories.count == 0 {
            getQuizzes(nil)
        }
    }
    
    @objc func getQuizzes(_ sender: UIRefreshControl?) {
        if let sender = sender {sender.beginRefreshing()}
        fs.collection("Quizzes").getDocuments { (snapshot, err) in
            if let err = err {
                print("ERROR: \(err)")
                if let sender = sender {sender.endRefreshing()}
                self.showAlert(title: "Error: Could not retrieve data", message: err.localizedDescription)
                return
            }
            guard let snapshot = snapshot else {return}
            var tempCategories: [Quiz] = []
            var i = 0
            for document in snapshot.documents {
                i += 1
                let data = document.data()
                print("Adding quiz")
                tempCategories.append(
                    Quiz(
                        title: data["Title"] as! String,
                        desc: nil,
                        questions: data["Questions"] as! [String],
                        answers: data["Answers"] as! [String],
                        imageName: data["ImageName"] as! String
                    ))
                if i >= snapshot.documents.count {
                    print("Finished getting quizzes")
                    if let sender = sender {sender.endRefreshing()}
                    quizCategories = tempCategories
                    saveQuizzes()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func refreshChanged(_ sender: UIRefreshControl) {
        getQuizzes(sender)
    }
    
    var ref: DocumentReference?
    var fs: Firestore!

}

class QuizCenterRectCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
}
