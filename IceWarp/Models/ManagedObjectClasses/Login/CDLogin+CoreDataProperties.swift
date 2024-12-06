//
//  CDLogin+CoreDataProperties.swift
//  IceWarp
//
//  Created by Ajay on 06/12/24.
//
//

import Foundation
import CoreData


extension CDLogin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDLogin> {
        return NSFetchRequest<CDLogin>(entityName: "CDLogin")
    }

    @NSManaged public var email: String?
    @NSManaged public var host: String?

}

extension CDLogin : Identifiable {

}

extension CDLogin: EntityConvertible {
    typealias ModelType = LoginModel
    
    func toModel() -> LoginModel {
        return LoginModel(authorized: false, token: "", host: self.host, email: self.email, ok: false)
    }
}
