//
//  InputValidator.swift
//  IceWarp
//
//  Created by Ajay on 05/12/24.
//

import UIKit

class InputValidator {
    func validate(username: String, password: String, hostname: String) throws {
        guard !username.isEmpty, !password.isEmpty, !hostname.isEmpty else {
            throw ValidationError.emptyFields
        }
        guard isValidEmail(username) else {
            throw ValidationError.invalidEmail
        }
        guard password.count >= 6 else {
            throw ValidationError.shortPassword
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    enum ValidationError: LocalizedError {
        case emptyFields, invalidEmail, shortPassword
        
        var errorDescription: String? {
            switch self {
            case .emptyFields: return "Fields cannot be empty."
            case .invalidEmail: return "Username must be a valid email."
            case .shortPassword: return "Password must be at least 6 characters long."
            }
        }
    }
}
