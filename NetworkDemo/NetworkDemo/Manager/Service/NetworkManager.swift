//
//  NetworkManager.swift
//  NetworkDemo
//
//  Created by Israkul Tushaer-81 on 11/1/24.
//


import UIKit
import Alamofire
import Combine
import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    func request<T: Decodable>(
            baseURL: String,
            path: String,
            method: HTTPMethod = .get,
            headers: HTTPHeaders? = nil,
            parameters: Parameters? = nil,
            dataModelType: T.Type
        ) -> AnyPublisher<T, AFError> {
            let url = baseURL
            return Future { promise in
                AF.request(url, method: method, parameters: parameters, headers: headers)
                    .validate()
                    .responseDecodable(of: T.self) { response in
                        switch response.result {
                        case .success(let value):
                            promise(.success(value))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
            }
            .eraseToAnyPublisher()
        }
}

