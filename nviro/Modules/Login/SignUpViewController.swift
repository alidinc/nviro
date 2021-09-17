//
//  SignUpViewController.swift
//  nviro
//
//  Created by Ali Dinç on 04/09/2021.
//

import Firebase
import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Helpers
    fileprivate func setupView() {
        signUpButton.layer.cornerRadius = 10
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirm = confirmPasswordTextField.text, !confirm.isEmpty,
              confirm == password else {
            self.showAlert(title: "Error", message: Constants.ErrorMessages.credentials)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                let storyboard = UIStoryboard(name: Constants.Storyboards.main, bundle: nil)
                let tabBarVC = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.tabBarVC)
                tabBarVC.modalPresentationStyle = .fullScreen
                self.present(tabBarVC, animated: true, completion: nil)
            }
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        return true
    }
}

