//
//  CreateAccountViewController.swift
//  E-chase
//
//  Created by Parth Saxena on 1/7/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit
import Firebase
import GradientCircularProgress

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var progress: GradientCircularProgress!
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.fullNameTextField.textColor = UIColor.white
        self.emailTextField.textColor = UIColor.white
        self.passwordTextField.textColor = UIColor.white
        self.fullNameTextField.attributedPlaceholder = NSAttributedString(string: "Full Name...",
                                                                       attributes: [NSForegroundColorAttributeName: UIColor.white])
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email...",
                                                                       attributes: [NSForegroundColorAttributeName: UIColor.white])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password...",                                                               attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        progress = GradientCircularProgress()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccountTapped(sender: Any) {
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
        if let fullName = self.fullNameTextField.text, let email = self.emailTextField.text, let password = self.passwordTextField.text {
            self.createAccount(fullName: fullName, email: email, password: password, completion: { (success) in
                if success {
                    // successfully created user's account
                    print("Successfully created user's account")
                    DispatchQueue.main.async {
                        self.progress.dismiss()
                        UIView.animate(withDuration: 0.25, animations: {
                            self.blurEffectView.effect = nil
                        }, completion: { (success) in
                            self.blurEffectView.removeFromSuperview()
                        })
                    }
                    let alert = UIAlertController(title: "Awesome!", message: "Your account has been created. Let's get started!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "CreateAccountToAppDescription", sender: nil)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // failed to create user's account
                    print("Failed to create user's account")
                    DispatchQueue.main.async {
                        self.progress.dismiss()
                        UIView.animate(withDuration: 0.25, animations: {
                            self.blurEffectView.effect = nil
                        }, completion: { (success) in
                            self.blurEffectView.removeFromSuperview()
                        })
                    }
                    let alert = UIAlertController(title: "Sorry!", message: "There was an error creating your account...", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alert.view.tintColor = UIColor.red
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func createAccount(fullName: String, email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if user != nil {
                // created user in authentication, create user in database
                if let uid = FIRAuth.auth()?.currentUser?.uid {
                    let userObject = ["fullname": fullName, "email": email, "uid": uid, "address":""]
                    FIRDatabase.database().reference().child("users").child(uid).setValue(userObject)
                    completion(true)
                }
            } else {
                completion(false)
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
