//
//  ResourceGuideHomeVC.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/10/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Alamofire

class QuizCenterVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quizCategories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizCenterCell", for: indexPath) as! QuizCenterRectCell
//        cell.backView.layer.cornerRadius = 10
        cell.layer.cornerRadius = 15
        cell.backgroundView = {
            let imageView = UIImageView(image: UIImage(named: "cellgray"))
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        cell.backgroundView?.clipsToBounds = true
        cell.backgroundView?.layer.cornerRadius = 15
        cell.title.text = quizCategories[indexPath.row].title
        cell.icon.image = UIImage(named: quizCategories[indexPath.row].imageName)
        
//        cell.layer.cornerRadius = 20
        cell.layer.shadowColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1).cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 12)
        cell.layer.shadowRadius = 20
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 20).cgPath
        cell.layer.masksToBounds = false
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openQuiz", sender: quizCategories[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openQuiz" {
            let VC = segue.destination as! QuizCategoryVC
            VC.quiz = (sender as! Quiz)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interitem: CGFloat = 16
        let edgeinset: CGFloat = 20
        let deviceModel = UIDevice.current.model
        let deviceOrientation = UIDevice.current.orientation
        let cellsPerRow: CGFloat
        
        print("Device: \(deviceModel), isPortait: \(deviceOrientation.isPortrait), isLandscape: \(deviceOrientation.isLandscape), isValid: \(deviceOrientation.isValidInterfaceOrientation)")
        
        switch deviceModel {
        case "iPad":
            if deviceOrientation.isPortrait {cellsPerRow = 4}
            else if !deviceOrientation.isValidInterfaceOrientation {cellsPerRow = 4}
            else {cellsPerRow = 6}
        default:
            if deviceOrientation.isPortrait {cellsPerRow = 2}
            else if !deviceOrientation.isValidInterfaceOrientation {cellsPerRow = 2}
            else {cellsPerRow = 3}
        }
        
        return CGSize(
            width: (collectionView.bounds.width-2*edgeinset-(cellsPerRow-1)*interitem)/cellsPerRow,
            height: 128)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        
        collectionView.backgroundView = {
            let imageView = UIImageView(image: UIImage(named: "lime"))
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
        getQuizzes(nil)
    }
    
    @objc func getQuizzes(_ sender: UIRefreshControl?) {
        if let sender = sender {sender.beginRefreshing()}
        
        let rm = NetworkReachabilityManager()
        rm?.startListening(onUpdatePerforming: { _ in
            if let hasWifi = rm?.isReachable, hasWifi {
                print("Has WiFi")
            } else {
                print("No WiFi")
                self.showAlert(title: "Not connected to internet", message: "You are currently not connected to the internet. Certain documents may not load from the server.")
                if let sender = sender {sender.endRefreshing()}
                return
            }
        })
        
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
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
}
