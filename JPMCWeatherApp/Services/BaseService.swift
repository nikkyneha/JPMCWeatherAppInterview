//
//  BaseService.swift
//  JPMCWeatherApp
//
//  Created by Neha Dhawal on 8/16/24.
//

import Foundation

enum NetworkError: Error, Equatable {
    
    case badURL
    case requestFailed
    case unknown
    case decodingError(Error)
    case serverError(statusCode: Int)
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

class BaseService {
    
    // Generic method to perform a network request and parse the response into a Decodable model
    func performRequest<T: Decodable>(url: URL?, expecting: T.Type) async throws -> T {
        guard let url = url else {
            throw NetworkError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
        }
        
        // If the type is Data, we don't need to Json decode it. Data type is used to get icons.
        if T.self == Data?.self {
            if let dataAsT = data as? T {
                return dataAsT
            } else {
                throw NetworkError.decodingError(NSError(domain: "TypeCastingError", code: -1, userInfo: nil))
            }
        }
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
