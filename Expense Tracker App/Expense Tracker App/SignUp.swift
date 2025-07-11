//
//  SignUp.swift
//  Expense Tracker App
//
//  Created by Techpedia LTD on 09/07/2025.
//

import UIKit
import FirebaseAuth

class SignUp: UIViewController {
    
    let email = UITextField()
    let password = UITextField()
    let confirmPassword = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        signupView()
    }
    
    func signupView(){
        email.placeholder = "Please Enter your Email!"
        email.borderStyle = .roundedRect
        email.frame = CGRect(x: 40, y: 150, width: view.frame.width - 80, height: 44)
        email.autocapitalizationType = .none
        view.addSubview(email)
        
        password.placeholder = "Please Enter your password!!"
        password.borderStyle = .roundedRect
        password.isSecureTextEntry = true
        password.frame = CGRect(x: 40, y: 210, width: view.frame.width - 80, height: 44)
        password.autocapitalizationType = .none
        password.autocorrectionType = .no
        view.addSubview(password)
        
        confirmPassword.placeholder = "Please Confirm your password!!"
        confirmPassword.borderStyle = .roundedRect
        confirmPassword.isSecureTextEntry = true
        confirmPassword.frame = CGRect(x: 40, y: 270, width: view.frame.width - 80, height: 44)
        password.autocorrectionType = .no
        password.autocapitalizationType = .none
        view.addSubview(confirmPassword)
        
        let signupButton = UIButton(type: .system)
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.frame = CGRect(x: 40, y: 340, width: 80, height: 44)
        signupButton.backgroundColor = .blue
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.layer.cornerRadius = 8
        signupButton.addTarget(self, action: #selector(handleinput), for: .touchUpInside)
        view.addSubview(signupButton)
    }
    
    @objc func handleinput(){
        
        let email = email.text ?? ""
        let pass = password.text ?? ""
        let confirm = confirmPassword.text ?? ""
        
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert("Email is required.")
            return
        }
        
        //Should Learn afterwards
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            if !predicate.evaluate(with: email) {
                showAlert("Enter a valid email address.")
                return
        }
        
        if pass.isEmpty || confirm.isEmpty {
            showAlert("Password is required!")
            return
        }
        
        if pass.count < 6 {
            showAlert("Password must be at least 6 characters.")
            return
        }
        
        if confirm != pass {
            showAlert("Passwords do not match!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: pass) { authResult , error in
            
            if let error = error {
                showAlert("Authentication Failed \(error.localizedDescription)")
                return
            }
            showAlert("Account Created Successfully!!")
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true, completion: nil)
        }
        
        func showAlert(_ message: String) {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)
        }
        
    }
}
