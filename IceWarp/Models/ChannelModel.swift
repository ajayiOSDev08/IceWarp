//
//  ChannelModel.swift
//  IceWarp
//
//  Created by Ajay on 05/12/24.
//

import CoreData

// Channel Model
struct Channel: Codable {
    let channels: [ChannelList]
    let ok: Bool
}

// Channel List Model
struct ChannelList: Codable {
    let id, name, creator, groupEmail, groupFolderName: String?
    let isMember, isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, creator
        case isMember = "is_member"
        case groupEmail = "group_email"
        case groupFolderName = "group_folder_name"
        case isActive = "is_active"
    }
}

extension ChannelList: ModelConvertible {
    func toEntity(context: NSManagedObjectContext) -> CDChannelList {
        let entity = CDChannelList(context: context)
        entity.id = self.id
        entity.name = self.name
        entity.creator = self.creator
        entity.groupEmail = self.groupEmail
        entity.groupFolderName = self.groupFolderName
        entity.isMember = self.isMember
        entity.isActive = self.isActive
        return entity
    }
}
