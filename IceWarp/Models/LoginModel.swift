//
//  LoginModel.swift
//  IceWarp
//
//  Created by Ajay on 05/12/24.
//

import CoreData

// Login Response Model
struct LoginModel: Codable {
    let authorized: Bool
    let token, host, email: String?
    let ok: Bool
}

extension LoginModel: ModelConvertible {
    func toEntity(context: NSManagedObjectContext) -> CDLogin {
        let entity = CDLogin(context: context)
        entity.email = self.email
        entity.host = self.host
        return entity
    }
}
