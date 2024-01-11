//
//  HomeViewController.swift
//  NetworkDemo
//
//  Created by Israkul Tushaer-81 on 11/1/24.
//

import UIKit
import SwiftyJSON
import Alamofire

class HomeViewController: UIViewController {

    @IBOutlet weak var homeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let apiWithEndpoint = "https://api.themoviedb.org/3/search/movie?api_key=38e61227f85671163c275f9bd95a8803&query=marvel"

       NetworkManager.shared.fetchData(endpoint: apiWithEndpoint) { (result: Result<Movies, Error>) in
            switch result {
            case .success(let data):
                // Handle successful response
                print("Data: \(data.totalResults!)")
            case .failure(let error):
                // Handle error
                print("API request failed: \(error.localizedDescription)")
            }
        }
    }
    
}
