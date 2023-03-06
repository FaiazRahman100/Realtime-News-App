//
//  ApiCaller.swift
//  faiaz_rahman_30024_mid2
//
//  Created by bjit on 20/1/23.
//

import Foundation

func getNewsData(url: URL?, completion: @escaping (Result<[Articles], Error>) -> Void) {

    guard let url = url else {
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) {data, _, error in
        if let error = error {
            completion(.failure(error))
        }
        else if let data = data {
            
            do {
                let result = try JSONDecoder().decode(NewsData.self, from: data)
                completion(.success(result.articles))
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    task.resume()
}
