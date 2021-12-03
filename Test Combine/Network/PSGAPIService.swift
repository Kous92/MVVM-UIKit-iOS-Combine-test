//
//  APIService.swift
//  Test Combine
//
//  Created by Koussaïla Ben Mamar on 01/11/2021.
//

import Foundation
import Combine

final class PSGAPIService: APIService {
    var cancellables = Set<AnyCancellable>()
    private let playersURL = URL(string: "https://raw.githubusercontent.com/Kous92/JSON-test-data-with-GET/main/psgPlayers2021English.json")
    
    func fetchPlayers(completion: @escaping (Result<PSGPlayersResponse, APIError>) -> ()) {
        guard let url = playersURL else {
            completion(.failure(.invalidURL))
            
            return
        }
        
        getRequest(url: url, completion: completion)
    }
    
    // MARK: - Generic network layer for a GET HTTP call.
    private func getRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, APIError>) -> ()) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Network error
            guard error == nil else {
                print(error?.localizedDescription ?? "Network error")
                completion(.failure(.networkError))
                
                return
            }
            
            // No server response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.failed))
                
                return
            }
            
            switch httpResponse.statusCode {
                // Code 200, check if data exists
                case (200...299):
                    if let data = data {
                        var output: T?
                        
                        do {
                            output = try JSONDecoder().decode(T.self, from: data)
                        } catch {
                            completion(.failure(.decodeError))
                            return
                        }
                        
                        if let object = output {
                            completion(.success(object))
                        }
                    } else {
                        completion(.failure(.failed))
                    }
                default:
                    completion(.failure(.notFound))
            }
        }
        task.resume()
    }
}
