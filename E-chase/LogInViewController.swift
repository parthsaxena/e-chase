//
//  ViewController.swift
//  E-chase
//
//  Created by Parth Saxena on 1/6/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit
import Firebase
import GradientCircularProgress

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var progress: GradientCircularProgress!
    
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.emailTextField.textColor = UIColor.white
        self.passwordTextField.textColor = UIColor.white
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email...",
                                                               attributes: [NSForegroundColorAttributeName: UIColor.white])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password...",                                                               attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        progress = GradientCircularProgress()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInTapped(sender: Any) {
        self.view.endEditing(true)
        DispatchQueue.main.async {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
            self.blurEffectView = UIVisualEffectView()
            self.blurEffectView.frame = self.view.bounds
            self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(self.blurEffectView)
            UIView.animate(withDuration: 0.25, animations: {
                self.blurEffectView.effect = blurEffect
            })
            self.progress.show(style: LoadingStyle())
        }
        if let email = self.emailTextField.text, let password = self.passwordTextField.text {
            self.logInUser(email: email, password: password, completion: { (authenticated) in
                if authenticated {
                    // login successful
                    print("Logged in user.")
                    DispatchQueue.main.async {
                        self.progress.dismiss()
                        UIView.animate(withDuration: 0.25, animations: {
                            self.blurEffectView.effect = nil
                        }, completion: { (success) in
                            self.blurEffectView.removeFromSuperview()
                        })
                    }
                    self.performSegue(withIdentifier: "LogInToMain", sender: nil)
                } else {
                    // login failed
                    print("Authentication failed")
                    DispatchQueue.main.async {
                        self.progress.dismiss()
                        UIView.animate(withDuration: 0.25, animations: {
                            self.blurEffectView.effect = nil
                        }, completion: { (success) in
                            self.blurEffectView.removeFromSuperview()
                        })
                    }
                    let alert = UIAlertController(title: "Sorry!", message: "Incorrect Email/Password", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alert.view.tintColor = UIColor.red
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func logInUser(email: String, password: String, completion: @escaping (_ authenticated: Bool) -> Void) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if user != nil {
                completion(true)
            } else {
                completion(false)
            }
        })
    }

}

