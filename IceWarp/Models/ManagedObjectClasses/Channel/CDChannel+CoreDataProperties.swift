//
//  CDChannelList+CoreDataProperties.swift
//  IceWarp
//
//  Created by Ajay on 06/12/24.
//
//

import Foundation
import CoreData


extension CDChannelList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChannelList> {
        return NSFetchRequest<CDChannelList>(entityName: "CDChannelList")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var creator: String?
    @NSManaged public var groupEmail: String?
    @NSManaged public var groupFolderName: String?
    @NSManaged public var isMember: Bool
    @NSManaged public var isActive: Bool

}

extension CDChannelList : Identifiable {

}

extension CDChannelList: EntityConvertible {
    typealias ModelType = ChannelList
    
    func toModel() -> ChannelList {
        return ChannelList(id: self.id, name: self.name, creator: self.creator, groupEmail: self.groupEmail, groupFolderName: self.groupFolderName, isMember: self.isMember, isActive: self.isActive)
    }
}
        
