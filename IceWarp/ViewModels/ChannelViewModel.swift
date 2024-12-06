//
//  ChannelViewModel.swift
//  IceWarp
//
//  Created by Ajay on 06/12/24.
//

import CoreData

class ChannelViewModel {
        
    func fetchChannels(includeUnreadCount: Bool = true,
                       excludeMembers: Bool = true,
                       includePermissions: Bool = false) async throws -> [ChannelList] {
        
        guard let token = KeychainHelper.shared.getToken() else {
            throw NetworkError.invalidToken
        }
        
        // Try to fetch channels from the database first
        let channels = self.fetchChannelList()
        if !channels.isEmpty {
            // If channels exist in the database, use them offline
            return channels
        }
        
        // If no channels in the database, fetch from the API
        let parameters = "token=\(token)&include_unread_count=\(includeUnreadCount)&exclude_members=\(excludeMembers)&include_permissions=\(includePermissions)"
        let body = parameters.data(using: .utf8)
        
        // Fetch channels from the API
        let response: Channel = try await NetworkService.shared.request(url: APIEndpoints.shared.channelList, body: body)
        
        // Save the fetched channels into the database for offline use
        self.saveChannelList(channels: response.channels)
        
        return response.channels
    }
    
    func saveChannelList(channels: [ChannelList]) {
        let backgroundContext = CoreDataHelper.shared.backgroundContext
        backgroundContext.perform {
            
            for channel in channels {
                let entity = CDChannelList(context: backgroundContext)
                entity.id = channel.id
                entity.name = channel.name
                entity.creator = channel.creator
                entity.groupEmail = channel.groupEmail
                entity.groupFolderName = channel.groupFolderName
                entity.isMember = channel.isMember
                entity.isActive = channel.isActive
            }
            
            CoreDataHelper.shared.saveContext(backgroundContext)
        }
    }
    
    func fetchChannelList() -> [ChannelList] {
        let channelList = CoreDataHelper.shared.fetchEntities(ofType: CDChannelList.self).map { $0.toModel() }
        return channelList
    }
    
    func deleteAllData() {
        KeychainHelper.shared.deleteToken()
        CoreDataHelper.shared.deleteAllEntities(ofType: CDLogin.self)
        CoreDataHelper.shared.deleteAllEntities(ofType: CDChannelList.self)
        CoreDataHelper.shared.saveContext()
    }
}
