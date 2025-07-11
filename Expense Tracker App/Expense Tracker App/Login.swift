//
//  ViewController.swift
//  Expense Tracker App
//
//  Created by Techpedia LTD on 09/07/2025.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class Login: UIViewController {

    let nameField = UITextField()
    let password = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        mainfunc()
    }
    
    func mainfunc(){
        nameField.placeholder = "Please Enter your username!"
        nameField.borderStyle = .roundedRect
        nameField.frame = CGRect(x: 40, y: 150, width: view.frame.width - 80, height: 44)
        view.addSubview(nameField)
        
        password.placeholder = "Please Enter your password!!"
        password.borderStyle = .roundedRect
        password.isSecureTextEntry = true
        password.frame = CGRect(x: 40, y: 210, width: view.frame.width - 80, height: 44)
        view.addSubview(password)
        
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.frame = CGRect(x: 40, y: 270, width: 80, height: 44)
        loginButton.backgroundColor = .blue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(loginFunction), for: .touchUpInside)
        view.addSubview(loginButton)
        
        let signup = UIButton(type: .system)
        signup.setTitle("Sign Up", for: .normal)
        signup.frame = CGRect(x: view.frame.width - 110, y: 270, width: 80, height: 44)
        signup.addTarget(self, action: #selector(goSignUp), for: .touchUpInside)
        view.addSubview(signup)
        
        let googleButton = UIButton(type: .system)
        googleButton.setTitle("Sign in using Google", for: .normal)
        googleButton.frame = CGRect(x: view.frame.width - 110, y: 360, width: 80, height: 44)
        googleButton.addTarget(self, action: #selector(googleSignin), for: .touchUpInside)
        view.addSubview(googleButton)
    }
    
    
    @objc func loginFunction(){
        let email = nameField.text ?? ""
        let pass = password.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: pass) { authResult, error in
            if let error = error {
                self.showAlert("Login failed: \(error.localizedDescription)")
                return
            }
            self.showAlert("Login successful")
        }
        DispatchQueue.main.async {
            let home = Home()
            self.navigationFunction(home)
        }
    }
    
    @objc func googleSignin(){
        guard let clientID = FirebaseApp.app()?.options.clientID else {return}
        
        let _ = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: self) {[unowned self] result , error in
            if let error = error {
                self.showAlert("Google Sign-In error: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user ,
                  let idToken = user.idToken?.tokenString
            else {
                self.showAlert("Google authentication data missing")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) {result, error in
                if let error = error {
                    self.showAlert("Firebase Sign-In error: \(error.localizedDescription)")
                    return
                }
                self.showAlert("Google Sign-In successful!")
            }
            DispatchQueue.main.async {
                let home = Home()
                self.navigationFunction(home)
            }
        }
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    @objc func goSignUp(){
        let signup = SignUp()
        navigationFunction(signup)
    }
    
    @objc func navigationFunction(_ viewController: UIViewController){
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }

}

