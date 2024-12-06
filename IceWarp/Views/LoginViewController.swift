//
//  LoginViewController.swift
//  IceWarp
//
//  Created by Ajay on 04/12/24.
//

import UIKit

import UIKit

class LoginViewController: UIViewController {

    // Outlets for text fields
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signInBtn: UIButton!

    private var viewModel = LoginViewModel()
    private let validator = InputValidator()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // Dismiss the keyboard
    }

    private func setup() {
        // Set the delegate
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        hostTextField.delegate = self
        
        usernameTextField.becomeFirstResponder()

        loginView.layer.cornerRadius = 10
        errorLabel.text = ""
    }

    @IBAction func signInBtnTapped(_ sender: UIButton) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let hostname = hostTextField.text ?? ""

        Task {
            do {
                try validator.validate(username: username, password: password, hostname: hostname)
                await authenticateUser(username: username, password: password, hostname: hostname)
            } catch let validationError as InputValidator.ValidationError {
                showError(validationError.localizedDescription)
            } catch {
                showError("Unexpected error occurred.")
            }
        }
    }

    private func authenticateUser(username: String, password: String, hostname: String) async {
        showLoader()
        do {
            try await viewModel.login(username: username, password: password, hostname: hostname)
            hideLoader()
            navigateToChannelListVC()
        } catch {
            hideLoader()
            showError(error.localizedDescription)
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.textColor = .red
    }
}


extension LoginViewController: UITextFieldDelegate {

    // Called when the return button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.returnKeyType {
        case .continue:
            // Move focus to the next field dynamically
            if textField == usernameTextField {
                passwordTextField.becomeFirstResponder()
            } else if textField == passwordTextField {
                hostTextField.becomeFirstResponder()
            }
        case .done:
            textField.resignFirstResponder() // Dismiss the keyboard
        default:
            break
        }
        return true
    }
}



