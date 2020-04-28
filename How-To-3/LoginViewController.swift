//
//  LoginViewController.swift
//  How-To-3
//
//  Created by Bhawnish Kumar on 4/27/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit

enum LoginType: String {
    case signUp = "Register"
    case signIn = "Sign In"
}

class LoginViewController: UIViewController {
    
    
    var buttonToggle = false
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInLabel: UIButton!
    @IBOutlet weak var registerLabel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.isHidden = true
        // Do any additional setup after loading the view.
    }
    var backendController = BackendController()
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        buttonToggle.toggle()
        emailTextField.isHidden = false
        logInLabel.setTitle("Cancel", for: .normal)
        showAlertMessage(title: "Register!", message: "Please fill out the text fields", actiontitle: "Ok")
        
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            username.isEmpty == false,
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            password.isEmpty == false,
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            else { return }
        backendController.signUp(username: username, password: password, email: email) { signUpResult in
            
                    }
        
        
    }
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        emailTextField.isHidden = true
        logInLabel.setTitle("Sign In", for: .normal)
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func showAlertMessage(title: String,message: String, actiontitle: String) {
        let endAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let endAction = UIAlertAction(title: actiontitle, style: .default){ (action:UIAlertAction) in
            
        }
        endAlert.addAction(endAction)
        present(endAlert, animated: true, completion: nil)
    }
    
}
