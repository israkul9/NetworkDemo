
import Foundation
import Alamofire
import UIKit
import Combine

class HomeViewModel {
    
    var movieListDataSource = [Movie]()
    var subscription = Set<AnyCancellable>()
    var movieListSubject = PassthroughSubject<[Movie],Never>()
    
    func getData(baseUrl : String){
        let baseURL = baseUrl
        let path = "/endpoint"
        let headers: HTTPHeaders = ["Authorization": "Bearer YOUR_ACCESS_TOKEN"]
        let parameters: Parameters = ["key": "value"]
        NetworkManager.shared.request(
            baseURL: baseURL,
            path: path,
            method: .get,
            headers: headers,
            parameters: parameters,
            dataModelType: Movies.self
        )
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print("API Request Error: \(error)")
            }
        }, receiveValue: { [weak self] response in
            guard let self = self else  { return }
            if let movieList = response.results {
                self.movieListSubject.send(movieList)
            }

        })
        .store(in: &subscription)
    }
    
}
