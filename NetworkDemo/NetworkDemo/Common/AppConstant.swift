//
//  AppConstant.swift
//  NetworkDemo
//
//  Created by Israkul Tushaer-81 on 11/1/24.
//

import Foundation


struct StoryboardNames {
    static let Home = "Home"
   
}

struct ViewControllerNames {
    static let HomeVC = "HomeViewController"
    
}

struct ApiConstant {
   
    enum APIRequestType: String {
        case get
        case post
        case put
        case delete
        // Add more cases as needed

        var method: String {
            return self.rawValue.uppercased()
        }
    }
}
