//
//  APIEndpoints.swift
//  IceWarp
//
//  Created by Ajay on 06/12/24.
//

// APIEndpoints Model
struct APIEndpoints {
    private let baseURL: String

    var login: String { "\(baseURL)/teamchatapi/iwauthentication.login.plain" }
    var channelList: String { "\(baseURL)/teamchatapi/channels.list" }

    private init(host: String) {
        self.baseURL = "https://\(host)"
    }

    // Shared instance
    private static var sharedInstance: APIEndpoints?

    // Method to initialize or update the shared instance
    static func configure(host: String) {
        sharedInstance = APIEndpoints(host: host)
    }

    // Accessor for the shared instance
    static var shared: APIEndpoints {
        guard let instance = sharedInstance else {
            return APIEndpoints(host: "mofa.onice.io") // Default Host
        }
        return instance
    }
}
