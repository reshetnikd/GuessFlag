//
//  ViewController.swift
//  GuessTheFlag
//
//  Created by Dmitry Reshetnik on 21.02.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var correctAnswer = 0
    var score = 0
    var questions = 0
    var showScoreInTitle = false
    var highestScore = 0
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        highestScore = defaults.object(forKey: "highest") as? Int ?? 0
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .compose, target: self, action: #selector(showScore))
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
//        button3.layer.borderColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0).cgColor
//        countries.append("estonia")
//        countries.append("france")
//        .
//        .
//        countries.append("us")
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        askQuestion()
        // Send local notification that reminds players to come back and play every day.
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Come back and play!"
                content.body = "The more often you will play the better you will become in this game."
                content.categoryIdentifier = "alarm"
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: true)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            }
        }
    }
    
    @objc func showScore() {
        let ac = UIAlertController(title: "Score", message: "\(score)", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        correctAnswer = Int.random(in: 0...2)
//        title = countries[correctAnswer].uppercased()
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "\(countries[correctAnswer].uppercased())\nScore: \(score)"
        self.navigationItem.titleView = label
        
        if score > highestScore {
            highestScore = score
            defaults.set(highestScore, forKey: "highest")
            let ac = UIAlertController(title: "Congratulations!", message: "You set new High Score!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true)
        }
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.2,
            options: .curveLinear,
            animations: {
                sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveLinear,
                    animations: {
                        sender.transform = .identity
                    }
                )
            }
        )
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong"
            score -= 1
        }
        
        questions += 1
        
        if questions >= 10 {
            let ac = UIAlertController(title: title, message: sender.tag != correctAnswer ? "Wrong! That's the flag of \(countries[sender.tag].uppercased())\nYour final score is \(score)" : "Your final score is \(score).", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: title, message: sender.tag != correctAnswer ? "Wrong! That's the flag of \(countries[sender.tag].uppercased())" : "Your score is \(score).", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(ac, animated: true)
        }
    }
    
}

