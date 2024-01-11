//
//  NetworkManager.swift
//  NetworkDemo
//
//  Created by Israkul Tushaer-81 on 11/1/24.
//

import Foundation
import Alamofire
import SwiftyJSON


class NetworkManager {
    private let lock = NSLock()
    private var accessToken: String?
    private var refreshToken: String?
    private var retryCount = 0
    private let maxRetryCount = 3
    // Singleton
    static let shared = NetworkManager()
    // Private Init
    private init() {
        self.accessToken = "initial_access_token"
        self.refreshToken = "initial_refresh_token"
    }
    func makeRequest<T: Decodable>(url: String, method: HTTPMethod, parameters: Parameters? = nil, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        // Added lock for handle race condition
        lock.lock()
        defer { lock.unlock() }
        
        guard let accessToken = accessToken else {
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        
        AF.request(url, method: method, parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    if response.response?.statusCode == 401 && self.retryCount < self.maxRetryCount { // if status code is 401 , then try to retry for the refresh token
                        // Token expired, try refreshing now
                        self.retryCount += 1
                        self.refreshToken { result in
                            switch result {
                            case .success:
                                // Retry the original request with the new token
                                self.makeRequest(url: url, method: method, parameters: parameters, responseType: responseType, completion: completion) //-> This method is for request again with new access token
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    } else {
                        // Handle other errors
                        completion(.failure(error))
                    }
                }
            }
    }
    
    private func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
        // Replace the following URL with your actual refresh token endpoint
        let refreshTokenURL = "https://your-api.com/refresh_token"
        
        // Replace headers and parameters as needed
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(NetworkManager.shared.refreshToken ?? "")"
        ]
        
        AF.request(refreshTokenURL, method: .post, headers: headers).validate().responseDecodable(of: RefreshTokenType.self) { response in
            switch response.result {
            case .success(let value):
                // Assuming RefreshTokenType contains the new access token
                let newAccessToken = value.accessToken
                self.retryCount = 0 // Reset retry count on successful token refresh
                completion(.success(newAccessToken))
            case .failure(let error):
                // Handle error if the request fails
                completion(.failure(error))
            }
        }
    }
}
    
struct RefreshTokenType: Decodable {
    let accessToken: String
}

