//
//  LoginViewModel.swift
//  IceWarp
//
//  Created by Ajay on 05/12/24.
//

import UIKit

class LoginViewModel {

    func login(username: String, password: String, hostname: String) async throws {
        APIEndpoints.configure(host: hostname)
        let parameters = "username=\(username)&password=\(password)"
        let body = parameters.data(using: .utf8)

        let response: LoginModel = try await NetworkService.shared.request(url: APIEndpoints.shared.login, body: body)
        
        KeychainHelper.shared.saveToken(token: response.token)
        saveUser(email: username, hostname: hostname)
    }
    
    func saveUser(email: String, hostname: String) {
        let backgroundContext = CoreDataHelper.shared.backgroundContext
        backgroundContext.perform {
            let user = CDLogin(context: backgroundContext)
            user.email = email
            user.host = hostname

            CoreDataHelper.shared.saveContext(backgroundContext)
        }
    }
}




