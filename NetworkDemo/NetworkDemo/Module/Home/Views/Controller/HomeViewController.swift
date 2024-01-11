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
    var viewModel: HomeViewModel!
    
    @IBOutlet weak var homeTableView: UITableView! {
        didSet {
            homeTableView.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .cyan
        let apiWithEndpoint = "https://api.themoviedb.org/3/search/movie?api_key=38e61227f85671163c275f9bd95a8803&query=marvel"
        
        viewModel = HomeViewModel()
        
        viewModel.getData(baseUrl: apiWithEndpoint) { success in
            if success {
                debugPrint("Data found")
            }
            else {
                debugPrint("Error , while getting data")
            }
        }

      
    }
    
}
