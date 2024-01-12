//
//  HomeViewModel.swift
//  NetworkDemo
//
//  Created by Israkul Tushaer-81 on 12/1/24.
//

import Foundation
import Alamofire
import SwiftyJSON


class HomeViewModel {
   
    func getData(baseUrl : String ,  completion: @escaping (Bool) -> Void){
        NetworkManager.shared.makeRequest(url: baseUrl, method: .get, responseType: Movies.self) { result in
            switch result {
            case .success(let responseModel):
                  // Handle success with your response model
                print(responseModel.totalPages!)
                completion(true)
              case .failure(let error):
                  // Handle failure
                  print(error.localizedDescription)
                completion(false)
              
            }
        }
    }
    
}
