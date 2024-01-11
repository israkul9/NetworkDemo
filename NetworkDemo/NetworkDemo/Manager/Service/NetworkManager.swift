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
    static let shared = NetworkManager()
    private var sessionManager: Session
    private var accessToken: String?  // Store  access token here
    private var refreshToken: String? // Store  refresh token here
    
    private init() {
        // Initialize your access and refresh tokens if available
        self.accessToken = "initial_access_token"
        self.refreshToken = "initial_refresh_token"
        
        // Initialize the Alamofire session manager
        self.sessionManager = Session(interceptor: TokenRefreshInterceptor())
    }
    
    func fetchData<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let accessToken = self.accessToken else {
            let error = NSError(domain: "NetworkDemo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Access token not available"])
            completion(.failure(error))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        sessionManager.request(endpoint, method: .get, headers: headers).validate().responseDecodable(of: T.self) { response in
            switch response.result {
                
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // Refresh token 
    private class TokenRefreshInterceptor: RequestInterceptor {
        private let lock = NSLock()
        private var retryCount = 0
        private let maxRetryCount = 3  // Set  desired maximum retry count
        
        func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
            var urlRequest = urlRequest
            
            if let accessToken = NetworkManager.shared.accessToken {
                urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            completion(.success(urlRequest))
        }
        
        func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
            guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
                completion(.doNotRetry)
                return
            }
            
            lock.lock()
            if retryCount < maxRetryCount {
                retryCount += 1
                lock.unlock()
                
                refreshToken { result in
                    switch result {
                    case .success(let newAccessToken):
                        // Update the access token and retry the request
                        NetworkManager.shared.accessToken = newAccessToken
                        completion(.retry)
                    case .failure(let error):
                        // Handle the token refresh error and do not retry
                        print("Token refresh failed: \(error.localizedDescription)")
                        completion(.doNotRetry)
                    }
                }
            } else {
                lock.unlock()
                // Retry limit reached, do not retry
                completion(.doNotRetry)
            }
        }
        
        private func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
            // Implement your token refresh logic here
            // Use Alamofire to make the refresh token request
            
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
                    completion(.success(newAccessToken))
                case .failure(let error):
                    // Handle error if the request fails
                    completion(.failure(error))
                }
            }
        }
    }
}

struct RefreshTokenType: Decodable {
    let accessToken: String
}
