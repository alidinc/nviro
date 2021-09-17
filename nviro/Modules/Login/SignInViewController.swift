//
//  ViewController.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import Firebase
import UIKit

class SignInViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Helpers
    fileprivate func setupView() {
        signInButton.layer.cornerRadius = 10
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func signInTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                let storyboard = UIStoryboard(name: Constants.Storyboards.main, bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.tabBarVC) as! UITabBarController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: Constants.Storyboards.main, bundle: nil)
        guard let signUpVC = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.signUpVC) as? SignUpViewController else { return }
        self.present(signUpVC, animated: true, completion: nil)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        return true
    }
}
