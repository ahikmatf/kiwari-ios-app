//
//  ViewController.swift
//  kiwari-ios-test
//
//  Created by aegislabs on 18/09/19.
//  Copyright © 2019 fatahillah. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailAddressHint: UILabel!
    @IBOutlet weak var passwordLabelHint: UILabel!
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        validateLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupView() {
        emailAddressHint.isHidden = true
        passwordLabelHint.isHidden = true
    }

    func validateLogin() {
        let email = emailAddressTextField.text
        let password = passwordTextField.text
        
        Auth.auth().signIn(withEmail: email!, password: password!) { [weak self] user, error in
            guard self != nil else { return }
            // ...
            if error == nil {
                self?.navigateToMainNavigation()
            } else {
                self?.displayErrorLoginAlert()
            }
        }
    }
    
    func navigateToMainNavigation() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let mainNavigationVC = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationController") as? MainNavigationController
            else {
                return
        }
        
        present(mainNavigationVC, animated: true, completion: nil)
    }

    func displayErrorLoginAlert() {
        let alert = UIAlertController(title: "Login Failed", message: "You have entered an invalid username or password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: - Helper Methods
    
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        print(text)
        
        if textField == emailAddressTextField {
            return (isValidEmail(emailStr: text), "Please check your email")
        }
        
        if textField == passwordTextField {
            return (text.count >= 6, "Your password is too short.")
        }
        
        return (text.count > 0, "This field cannot be empty.")
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        print(emailStr)
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case emailAddressTextField:
                // Validate Text Field
                let (valid, message) = validate(textField)
                
                // Update Email Validation Label
                self.emailAddressHint.text = message
                
                // Show/Hide Password Validation Label
                UIView.animate(withDuration: 0.25, animations: {
                    self.emailAddressHint.isHidden = valid
                })
                
                if valid {
                    emailAddressTextField.resignFirstResponder()
                    passwordTextField.becomeFirstResponder()
                }
            
            case passwordTextField:
                // Validate Text Field
                let (valid, message) = validate(textField)
                
                // Update Password Validation Label
                self.passwordLabelHint.text = message
                
                // Show/Hide Password Validation Label
                UIView.animate(withDuration: 0.25, animations: {
                    self.passwordLabelHint.isHidden = valid
                })
                
                if valid {
                    passwordTextField.resignFirstResponder()
                }
            
            default:
                emailAddressTextField.resignFirstResponder()
                passwordTextField.resignFirstResponder()
            }
        
        return true
    }
}
