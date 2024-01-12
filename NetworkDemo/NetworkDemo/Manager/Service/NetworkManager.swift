//
//  NetworkManager.swift
//  NetworkDemo
//
//  Created by Israkul Tushaer-81 on 11/1/24.
//

import Alamofire
import Foundation
import SwiftyJSON

class NetworkManager {
    private let lock = NSLock()
    private var accessToken: String?
    private var refreshToken: String?
    private var retryCount = 0
    private let maxRetryCount = 3
    private var requestCache: [AnyRetryableRequest] = [] // Cache for failed requests
    private var isRefreshing = false
    
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
            .responseDecodable(of: T.self) { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    if response.response?.statusCode == 401 && self.retryCount < self.maxRetryCount {
                        // If status code is 401, cache the request and refresh token
                        self.cacheRequest(url: url, method: method, parameters: parameters, responseType: responseType, completion: completion)
                        self.refreshAccessTokenIfNeeded()
                    } else {
                        // Handle other errors
                        completion(.failure(error))
                    }
                }
            }
    }
    
    private func cacheRequest<T: Decodable>(url: String, method: HTTPMethod, parameters: Parameters? = nil, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let retryableRequest = RetryableRequest(url: url, method: method, parameters: parameters, responseType: responseType, completion: completion)
        let anyRetryableRequest = AnyRetryableRequest(request: retryableRequest)
        requestCache.append(anyRetryableRequest)
    }
    
    private func refreshAccessTokenIfNeeded() {
        guard !isRefreshing else {
            return
        }
        
        if retryCount < maxRetryCount {
            // Retry the original request
            retryCount += 1
        } else {
            // Reset retry count on successful request
            retryCount = 0
            
            // If max retry count reached, clear the tokens and notify about the failure
            accessToken = nil
            refreshToken = nil
            return
        }
        
        isRefreshing = true
        refreshToken { [weak self] result in
            guard let self = self else { return }
            
            self.isRefreshing = false
            switch result {
            case .success:
                // Retry the enqueued requests after a successful token refresh
                self.retryEnqueuedRequests()
            case .failure:
                // If refresh token fails, clear the tokens and notify about the failure
                self.accessToken = nil
                self.refreshToken = nil
            }
        }
    }
    
    private func retryEnqueuedRequests() {
        for request in requestCache {
            request.makeRequest()
        }
        
        // Clear the request cache after retrying
        requestCache.removeAll()
    }
    
    private func refreshToken(completion: @escaping (Result<Void, Error>) -> Void) {
        // Replace the following URL with your actual refresh token endpoint
        let refreshTokenURL = "https://your-api.com/refresh_token"
        
        // Replace headers and parameters as needed
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(NetworkManager.shared.refreshToken ?? "")"
        ]
        
        AF.request(refreshTokenURL, method: .post, headers: headers)
            .validate()
            .responseDecodable(of: RefreshTokenType.self) { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case .success(let value):
                    // Assuming RefreshTokenType contains the new access token
                    let newAccessToken = value.accessToken
                    self.accessToken = newAccessToken
                    completion(.success(()))
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

struct RetryableRequest<T: Decodable> {
    let url: String
    let method: HTTPMethod
    let parameters: Parameters?
    let responseType: T.Type
    let completion: (Result<T, Error>) -> Void

    func makeRequest() {
        NetworkManager.shared.makeRequest(url: url, method: method, parameters: parameters, responseType: responseType, completion: completion)
    }
}

struct AnyRetryableRequest {
    private let makeRequestClosure: () -> Void

    init<T: Decodable>(request: RetryableRequest<T>) {
        makeRequestClosure = {
            request.makeRequest()
        }
    }

    func makeRequest() {
        makeRequestClosure()
    }
}
