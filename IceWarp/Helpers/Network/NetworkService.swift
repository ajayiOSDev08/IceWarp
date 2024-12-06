//
//  NetworkService.swift
//  IceWarp
//
//  Created by Ajay on 04/12/24.
//

import Foundation

class NetworkService {

    static let shared = NetworkService()

    private init() { }

    // MARK: - Network Request Method
    func request<T: Codable>(
        url: String,
        method: HTTPMethod = .post,
        body: Data? = nil,
        headers: [String: String]? = nil,
        timeout: TimeInterval = 30
    ) async throws -> T {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.timeoutInterval = timeout // Timeout for the request
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200...299:
                break
            case 400:
                throw NetworkError.badRequest
            case 401:
                throw NetworkError.unauthorized
            case 404:
                throw NetworkError.notFound
            default:
                throw NetworkError.serverError
            }

            // Decode JSON
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            if let networkError = error as? NetworkError {
                throw networkError
            }
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
}


// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Error Handling
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError(String)
    case badRequest
    case unauthorized
    case notFound
    case serverError
    case invalidToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .noData:
            return "No data received from the server."
        case .decodingError(let message):
            return "\(message)"
        case .badRequest:
            return "Bad request (400)."
        case .unauthorized:
            return "Unauthorized (401)."
        case .notFound:
            return "Resource not found (404)."
        case .serverError:
            return "Server error occurred."
        case .invalidToken:
            return "Missing authentication token."
        }
    }
}
