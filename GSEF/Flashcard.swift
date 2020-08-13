//
//  Flashcard.swift
//  GSEF
//
//  Created by Pranav Ramesh on 8/12/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class Flashcard: UIViewController {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var text: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        commonInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    class func instanceFromNib() -> Flashcard {
        return UINib(nibName: "Flashcard", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! Flashcard
    }
    
//    func commonInit() {
//        Bundle.main.loadNibNamed("Flashcard", owner: self, options: nil)
//        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchView)))
//    }
    
    var question: String! /*{
        didSet {
            if isTurned {
                self.text.text = question
            } else {
                self.text.text = answer
            }
        }
    }*/
    var answer: String! /*{
        didSet {
            if isTurned {
                self.text.text = question
            } else {
                self.text.text = answer
            }
        }
    }*/
    var cardIndex: Int!
    var isTurned = false
    
    @objc func switchView() {
        isTurned = !isTurned
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) {
            if self.isTurned {
                self.text.text = self.answer
            } else {
                self.text.text = self.question
            }
        } completion: { (_) in
            self.text.layoutIfNeeded()
        }
    }

}
