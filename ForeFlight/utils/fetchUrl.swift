//
//  fetchUrl.swift
//  ForeFlight
//
//  Created by Frederik Helth on 25/01/2024.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidData
    case invalidResponse
}

enum CachePolicy {
    case returnCacheDataElseLoad
    case reloadIgnoringLocalCacheData
}

func fetchData<T: Decodable>(
    from url: URL, headers: [String: String]? = nil,
    cachePolicy: CachePolicy = .returnCacheDataElseLoad,
    completion: @escaping (Result<T, NetworkError>) -> Void) {
    var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
    
    // Set the specified cache policy
       switch cachePolicy {
       case .returnCacheDataElseLoad:
           request.cachePolicy = .returnCacheDataElseLoad
       case .reloadIgnoringLocalCacheData:
           request.cachePolicy = .reloadIgnoringLocalCacheData
       }
    
    if let headers = headers {
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("error string: \(error.localizedDescription)")
                completion(.failure(.invalidData))
            }
        }
    }.resume()
}
