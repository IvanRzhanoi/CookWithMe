//
//  LoginViewController.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 21/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    
    var userUID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(AddDishViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddDishViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
//            performSegue(withIdentifier: "toMessages", sender: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func keyboardWillShow(notify: NSNotification) {
        if let userInfo = notify.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            
            UIView.animate(withDuration: 5) {
                self.toolBarBottomConstraint.constant = -keyboardFrame!.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notify: NSNotification) {
        UIView.animate(withDuration: 5) {
            self.toolBarBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSignUp" {
            if let destination = segue.destination as? SignupViewController {
                if self.userUID != nil {
                    destination.userUID = userUID
                }
                
                if self.emailTextField.text != nil {
                    destination.emailText = emailTextField.text
                }
                
                if self.passwordTextField != nil {
                    destination.passwordText = passwordTextField.text
                }
            }
        }
    }
    
    func displayAlertMessage(messageToDisplay: String) {
        let alertController = UIAlertController(title: "Alert", message: messageToDisplay, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            // Code in this block will trigger when OK button tapped.
            //            print("Ok button tapped");
        }
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signIn(_ sender: Any) {
        if emailTextField.text!.isValidEmail() && (passwordTextField.text!.count >= 6) {
            print("Email address is valid")
        } else if !(emailTextField.text!.isValidEmail()) {
            displayAlertMessage(messageToDisplay: "Email address is not valid")
        } else {
            displayAlertMessage(messageToDisplay: "Password must be at least 6 characters long")
        }
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    self.userUID = user?.user.uid
                    KeychainWrapper.standard.set(self.userUID, forKey: "uid")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        switch errorCode {
                        case .wrongPassword:
                            self.displayAlertMessage(messageToDisplay: "Wrong Password")
                        case .userNotFound:
                            self.performSegue(withIdentifier: "toSignUp", sender: nil)
                        default:
                            self.displayAlertMessage(messageToDisplay: "Uknown Error")
                        }
                    }
                }
            })
        }
    }
}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
